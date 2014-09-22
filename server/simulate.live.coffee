class LiveSimulator
  constructor: (config) ->
    @config = config
    # TODO model beacons as collection?
    @beacons = readBeacons(config)

    liveMode = config.liveMode
    @maxVisitorsInLocation = liveMode.maxVisitorsInLocation
    @visitorFactory = new VisitorFactory(liveMode.visitorTypes, @beacons, liveMode.secondsPerBeacon, liveMode.secondsBetweenBeacons)

    if Meteor.settings.firebase.config
      console.warn "Loading beacons from config file while observing Firebase:", @beacons if config.beacons?
      firebaseURL = Meteor.settings.firebase.config + "/companies"
      @observeBeaconsFromFirebase(firebaseURL)

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
    console.log("Starting LIVE mode with #{JSON.stringify(@config.liveMode)}")

    # Create initial group of simulated visitors
    _(@maxVisitorsInLocation).times (n) =>
      @spawn()

    # Re spawn when needed
    Visitors.find().observe
      "removed": (oldDoc) =>
        @spawn()


@simulateLiveMode = (config) ->
  simulator = new LiveSimulator config
  simulator.run()


# returns array of entrances, products and cashiers beacon
readBeacons = (config) ->
  beacons = {entrances: [], products: [], cashiers: []}

  for name, beacon of config.beacons
    if name.indexOf("entrance") >= 0
      beacons.entrances.push(beacon)
    else if name.indexOf("product") >= 0
      beacons.products.push(beacon)
    else if name.indexOf("cashier") >= 0
      beacons.cashiers.push(beacon)

  beacons
