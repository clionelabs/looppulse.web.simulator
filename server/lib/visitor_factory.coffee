class VisitorFactory
  constructor: (behaviour, beacons, productBeaconMap, allProducts) ->
    @simClock = SimClock.get()
    @beacons = beacons
    @behaviour = behaviour
    @periods = behaviour.periods
    @visitorTypes = behaviour.visitorTypes
    @periodTypes = behaviour.periodTypes
    @secondsPerBeacon = behaviour.secondsPerBeacon
    @secondsBetweenBeacons = behaviour.secondsBetweenBeacons
    @productBeaconMap = productBeaconMap
    @allProducts = allProducts

    @counterSampledVisitorTypes = {}
    @counterSampledProducts = {}

  # compute the final product weights for visitor type, given their preferences
  buildVisitorTypesProductWeight: (visitorType) ->
    weights = []
    for productKey, product of @allProducts
      weight = 1.0
      categoryPreferences = visitorType.categoryPreferences
      productPreferences = visitorType.productPreferences
      if categoryPreferences
        for catPreference in categoryPreferences
          if catPreference.categoryName == product.category
            weight *= catPreference.weight
      if productPreferences
        for proPreference in productPreferences
          if proPreference.productName == productKey
            weight *= proPreference.weight
      weights.push({"productKey": productKey, "weight": weight})
    return weights

  # Given an array of weights (in float), sample the index probabilistically
  sampleWithWeights: (weights) ->
    sumWeight = 0.0
    for weight in weights
      sumWeight += weight
    rnd = sumWeight * Math.random()

    cumWeight = 0.0
    for weight, i in weights
      cumWeight += weight
      if rnd <= cumWeight
        return i

    console.error("invalid weights")
    return 0

  # Sample a visitor type probabilistically
  sampleVisitorType: (visitorTypesRatio) ->
    weights = []
    visitorTypes = []
    for visitorType in @visitorTypes
      weight = 1.0
      for visitorTypeRatio in visitorTypesRatio
        if visitorTypeRatio.visitorType == visitorType.name
          weight *= visitorTypeRatio.weight
      visitorTypes.push(visitorType)
      weights.push(weight)
    sampledVisitorType = visitorTypes[@sampleWithWeights(weights)]

    if !@counterSampledVisitorTypes[sampledVisitorType.name]
      @counterSampledVisitorTypes[sampledVisitorType.name] = 1
    else
      @counterSampledVisitorTypes[sampledVisitorType.name]++

    return sampledVisitorType

  # Sample a product for the visitor browse action probabilistically according to preferences
  sampleBrowseProduct: (visitorType) ->
    productWeights = @buildVisitorTypesProductWeight(visitorType)
    weights = []
    products = []
    for pw in productWeights
      weights.push(pw.weight)
      products.push(pw.productKey)
    productKey = products[@sampleWithWeights(weights)]

    sampledProduct = @productBeaconMap[productKey]

    if !@counterSampledProducts[productKey]
      @counterSampledProducts[productKey] = 1
    else
      @counterSampledProducts[productKey]++

    return sampledProduct

  # Sample a stay duration for the visitor
  sampleStayProductDuration: (visitorType) ->
    mean = visitorType.stayTime.mean
    std = visitorType.stayTime.std

    duration = Math.round(Random.gaussian(mean, std))
    duration = Math.max(0, duration)

    return duration * 1000

  # Get current behaviour period
  getCurrentPeriod: ->
    dt = @simClock.getNow()
    currentMinuteOfDay = parseInt(dt.format('m')) + 60 * parseInt(dt.format('H'))
    console.log('[VisitorFactory] current: ', dt.format(), ', currentMinuteOfDay', currentMinuteOfDay)

    for period in @periods
      if currentMinuteOfDay >= period.startMin && currentMinuteOfDay <= period.endMin
        return @getPeriodType(period.periodType)
    return null

  getPeriodType: (name) ->
    for periodType in @periodTypes
      if periodType.name == name
        return periodType
    return null

  # We use strategy pattern to dynamically inject the action strategies into the visitor
  generate: () ->
    period = @getCurrentPeriod()

    #console.log("[Generator] current period: ", JSON.stringify(period))

    if period == null
      return

    maxVisitors = period.maxVisitors
    remainVisitors = maxVisitors - Visitors.find({state: {$ne:"revisiting"}}).count()

    if remainVisitors <= 0
      return

    factory = @
    secondsPerBeacon = @secondsPerBeacon
    secondsBetweenBeacons = @secondsBetweenBeacons
    for n in [1..remainVisitors]
      visitorType = @sampleVisitorType(period.visitors)

      browseStrategy = () ->
        do (visitorType, factory) ->
          return factory.sampleBrowseProduct(visitorType)

      stayProductDurationStrategy = () ->
        do (visitorType, factory) ->
          return factory.sampleStayProductDuration(visitorType)

      stayGeneralDurationStrategy = () ->
        do (secondsPerBeacon) ->
            return 1000 * Random.seconds(secondsPerBeacon.min, secondsPerBeacon.max)

      travelDurationStrategy = () ->
        do (secondsBetweenBeacons) ->
            return 1000 * Random.seconds(secondsBetweenBeacons.min, secondsBetweenBeacons.max)

      revisitDurationStrategy = () ->
        do () ->
          # Randomly stay and and return in 1 to 7 days.
          return 1000 * Random.seconds(1, 7) * 3600

      strategies = {
        'visitorType': visitorType.name,
        'browseStrategy': browseStrategy,
        'stayProductDurationStrategy': stayProductDurationStrategy,
        'stayGeneralDurationStrategy': stayGeneralDurationStrategy,
        'travelDurationStrategy': travelDurationStrategy,
        'revisitDurationStrategy': revisitDurationStrategy
      }

      visitor = new Visitor(@beacons, strategies)
      visitor.enter()

    console.log("[Generator] statistics", JSON.stringify(@counterSampledVisitorTypes), JSON.stringify(@counterSampledProducts))

  start: () ->
    factory = @
    @simClock.setInterval((=> factory.generate()), 60 * 1000)

@VisitorFactory = VisitorFactory
