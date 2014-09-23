class VisitorFactory
  constructor: (visitorTypes, beacons, secondsPerBeacon, secondsBetweenBeacons, productBeaconMap) ->
    @beacons = beacons
    @secondsPerBeacon = secondsPerBeacon
    @secondsBetweenBeacons = secondsBetweenBeacons
    @visitorTypes = visitorTypes
    @productBeaconMap = productBeaconMap

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
  sampleVisitorType: () ->
    weights = []
    for visitorType in @visitorTypes
      weights.push visitorType.generateWeight
    return @visitorTypes[@sampleWithWeights(weights)]

  # Sample a product for the visitor browse action probabilistically according to preferences
  sampleBrowseProduct: (productPreferences) ->
    weights = []
    for product in productPreferences
      weights.push product.weight
    productName = productPreferences[@sampleWithWeights(weights)].productName
    if @productBeaconMap[productName]
      return @productBeaconMap[productName]
    console.error("invalid product")

  # We use strategy pattern to dynamically inject the action strategies into the visitor
  generate: () ->
    visitorType = @sampleVisitorType()
    factory = @
    browseStrategy = () ->
      do (visitorType, factory) ->
        product = factory.sampleBrowseProduct(visitorType.productPreferences)
        return product

    strategies = {
      'browseStrategy': browseStrategy
    }
    visitor = new Visitor(@beacons, @secondsPerBeacon, @secondsBetweenBeacons, strategies)

    return visitor

@VisitorFactory = VisitorFactory
