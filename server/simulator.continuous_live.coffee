class ContinuousLiveSimulator extends Simulator
  constructor: (config) ->
    @config = config

    @beacons = {entrances: [], products: [], cashiers: []}
    @productBeaconMap = {}
    @allProducts = {}

    @setApplicationPaths()

    behaviour = config.behaviour

    @maxVisitorsInLocation = behaviour.maxVisitorsInLocation
    @visitorFactory = new VisitorFactory(behaviour, @beacons, @productBeaconMap, @allProducts)

  setApplicationPaths: ->
    authUrl = @config.application.authURL
    result = HTTP.post(authUrl, {
      data: {
        session: {
          visitorUUID: '17dba1647591d871707bef5f',  # FIXME genertate this
          sdk: '0.0',
          device: 'simulator'
        }
      },
      headers: {
        'x-auth-token': @config.application.token
      }
    })
    console.log("Authenticated with", @config.application.authURL, JSON.stringify(result))
    @beaconEventsFbPath = result.data.system.firebase.beacon_events
    @engagementEventsFbPath = result.data.system.firebase.engagement_events

    firebaseRef = new Firebase(@beaconEventsFbPath)
    firebaseRef.auth result.data.system.firebase.token, Meteor.bindEnvironment (error, result) =>
      if error
        console.error('Login Failed!', @beaconEventsFbPath, error)
      else
        console.info('Authenticated successfully with payload:', result.auth)
        console.info('Auth expires at:', new Date(result.expires * 1000))
        @setupFirebase(@beaconEventsFbPath)
        @setupEngagementSimulation(@engagementEventsFbPath)

    @readBeacons(result.data.system)

  readBeacons: (companyConfig) ->
    console.info("[LiveSimulator] Adding products")
    for productKey, product of companyConfig.products
      console.info("[LiveSimulator] Adding product", JSON.stringify(product))
      @allProducts[productKey] = product

    console.info("[LiveSimulator] Adding beacons")
    for locationKey, locationConfig of companyConfig.locations
      for installationKey, installationConfig of locationConfig.installations
        data = companyConfig.products[installationConfig.product]
        type = data.type || "product"

        beaconConfig = installationConfig.beacon
        beacon = {
          uuid: beaconConfig.proximityUUID
          major: beaconConfig.major
          minor: beaconConfig.minor
        }
        console.info("[LiveSimulator] Adding beacon", JSON.stringify(beacon), type)
        switch type
          when "product"
            @beacons.products.push(beacon)
            @productBeaconMap[installationConfig.product] = beacon
          when "entrance"
            @beacons.entrances.push(beacon)
          when "cashier"
            @beacons.cashiers.push(beacon)
          else
            console.log("Unknown product type: #{type}")

  run: ->
    @visitorFactory.start()

@ContinuousLiveSimulator = ContinuousLiveSimulator
