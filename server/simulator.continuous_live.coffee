class ContinuousLiveSimulator extends Simulator
  constructor: (config) ->
    @config = config

    @setApplicationPaths()
    @setupFirebase(@beaconEventsFbPath)
    @setupEngagementSimulation(@engagementEventsFbPath)

    @beacons = {entrances: [], products: [], cashiers: []}
    @productBeaconMap = {}

    firebaseURL = Meteor.settings.firebase.config + "/companies"
    @observeBeaconsFromFirebase(firebaseURL)
    behaviour = config.behaviour

    @maxVisitorsInLocation = behaviour.maxVisitorsInLocation
    @visitorFactory = new VisitorFactory(behaviour.visitorTypes, @beacons, behaviour.secondsPerBeacon, behaviour.secondsBetweenBeacons, @productBeaconMap)

  setApplicationPaths: ->
    authUrl = @config.application.authURL
    result = HTTP.get(authUrl, {
      headers: {
        "x-auth-token": @config.application.token
      }
    })
    console.log("Authenticated with", JSON.stringify(result))
    @beaconEventsFbPath = result.data.system.firebase.beacon_events
    @engagementEventsFbPath = result.data.system.firebase.engagement_events

  observeBeaconsFromFirebase: (firebaseURL) ->
    console.info("[LiveSimulator] Observing beacons from Firebase", firebaseURL)
    firebase = new Firebase(firebaseURL)
    firebase.on "child_added",
      Meteor.bindEnvironment (childSnapshot, prevChildName) =>
        companyConfig = childSnapshot.val()
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

  spawn: ->
    if Visitors.find().count() < @maxVisitorsInLocation
      visitor = @visitorFactory.generate()
      visitor.enter()

  run: ->
    console.log("Starting LIVE mode with #{JSON.stringify(@config.behaviour)}")

    # Create initial group of simulated visitors
    _(@maxVisitorsInLocation).times (n) =>
      @spawn()

    # Re spawn when needed
    Visitors.find().observe
      "removed": (oldDoc) =>
        @spawn()

@ContinuousLiveSimulator = ContinuousLiveSimulator
