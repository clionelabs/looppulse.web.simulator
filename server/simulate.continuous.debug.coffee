class ContinuousDebugSimulator
  constructor: (config) ->
    @config = config
    # TODO model beacons as collection?
    @productBeaconMap = {}
    @readBeacons(config)

    behaviour = config.behaviour
    @maxVisitorsInLocation = behaviour.maxVisitorsInLocation
    @visitorFactory = new VisitorFactory(behaviour.visitorTypes, @beacons, behaviour.secondsPerBeacon, behaviour.secondsBetweenBeacons, @productBeaconMap)

  # returns array of entrances, products and cashiers beacon
  readBeacons: (config) ->
    @beacons = {entrances: [], products: [], cashiers: []}

    for name, beacon of config.beacons
      if name.indexOf("entrance") >= 0
        @beacons.entrances.push(beacon)
      else if name.indexOf("product") >= 0
        @beacons.products.push(beacon)
        @productBeaconMap[name] = beacon
      else if name.indexOf("cashier") >= 0
        @beacons.cashiers.push(beacon)

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


@simulateContinuousDebugMode = (config) ->
  simulator = new ContinuousDebugSimulator config
  simulator.run()
