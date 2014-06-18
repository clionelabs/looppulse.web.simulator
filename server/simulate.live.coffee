@simulateLiveMode = (config) ->
  liveMode = config.liveMode
  console.log("Starting LIVE mode with #{JSON.stringify(liveMode)}")

  beacons = readBeacons(config)

  spawn = () ->
    if Visitors.find().count() < liveMode.maxVisitorsInLocation
      visitor = new Visitor(beacons,
                            liveMode.secondsPerBeacon,
                            liveMode.secondsBetweenBeacons)
      visitor.enter()

  # Create initial group of simulated visitors
  _(liveMode.maxVisitorsInLocation).times (n) -> spawn()

  # Re spawn when needed
  Visitors.find().observe(
    "removed": (oldDoc) -> spawn()
  )

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
