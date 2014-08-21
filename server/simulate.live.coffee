class LiveSimulator
  constructor: (config) ->
    @config = config
    @beacons = readBeacons(config)

    liveMode = config.liveMode
    @maxVisitorsInLocation = liveMode.maxVisitorsInLocation
    @secondsPerBeacon = liveMode.secondsPerBeacon
    @secondsBetweenBeacons = liveMode.secondsBetweenBeacons

  spawn: ->
    if Visitors.find().count() < @maxVisitorsInLocation
      visitor = new Visitor(@beacons, @secondsPerBeacon, @secondsBetweenBeacons)
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
