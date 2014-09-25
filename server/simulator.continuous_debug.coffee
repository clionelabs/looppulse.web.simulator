class ContinuousDebugSimulator extends Simulator
  constructor: (config) ->
    super config

    fbBeaconEventsPath = @config.firebase.root + @config.firebase.beacon_events_path
    fbEngagementEventsPath = @config.firebase.root + @config.firebase.engagement_events_path
    @setupFirebase(fbBeaconEventsPath)
    @setupEngagementSimulation(fbEngagementEventsPath)
    
    @allProducts = {}
    @productBeaconMap = {}
    @readBeacons(config)

    @visitorFactory = new VisitorFactory(@config.behaviour, @beacons, @productBeaconMap, @allProducts)

  # returns array of entrances, products and cashiers beacon
  readBeacons: (config) ->
    @beacons = {entrances: [], products: [], cashiers: []}

    for name, beacon of config.beacons
      if name.indexOf("entrance") >= 0
        @beacons.entrances.push(beacon)
      else if name.indexOf("product") >= 0
        @beacons.products.push(beacon)
        @productBeaconMap[name] = beacon
        ## TODO: category is currently not supported for this simulator. categoryPreferences in the config file will be ignored
        @allProducts[name] = {"name": name, "category": "NOT_SUPPORTED"}
      else if name.indexOf("cashier") >= 0
        @beacons.cashiers.push(beacon)

  run: ->
    @visitorFactory.start()

@ContinuousDebugSimulator = ContinuousDebugSimulator
