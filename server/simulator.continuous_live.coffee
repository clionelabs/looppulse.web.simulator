class ContinuousLiveSimulator extends Simulator
  constructor: (config) ->
    @config = config

    @setApplicationPaths()

    @beacons = {entrances: [], products: [], cashiers: []}
    @productBeaconMap = {}
    @allProducts = {}

    firebaseURL = Meteor.settings.firebase.config + "/companies"
    @observeBeaconsFromFirebase(firebaseURL)
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

  observeBeaconsFromFirebase: (firebaseURL) ->
    console.info("[LiveSimulator] Observing beacons from Firebase", firebaseURL)
    firebase = new Firebase(firebaseURL)
    firebase.on "child_added",
      Meteor.bindEnvironment (childSnapshot, prevChildName) =>
        companyConfig = childSnapshot.val()

        console.info("[LiveSimulator] Adding categories and products")
        for productKey, product of companyConfig.products
          @allProducts[productKey] = product

        console.info("[LiveSimulator] Adding beacons from Firebase", companyConfig.name)
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
            console.info("[LiveSimulator] Adding beacon from Firebase", JSON.stringify(beacon), type)
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
