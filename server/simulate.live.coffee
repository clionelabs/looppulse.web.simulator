@simulateLiveMode = (config) ->
  liveMode = config.liveMode
  console.log("Starting LIVE mode with #{JSON.stringify(liveMode)}")

  beacons = readBeacons(config)

  #  Create first visitor
  visitor = new Visitor(beacons,
                        liveMode.secondsPerBeacon,
                        liveMode.secondsBetweenBeacons)
  visitor.enter()

  # spawn = () ->
  #   console.log("Current visitors: #{Visitors.find().count()}")
  #   if Visitors.find().count() < liveMode.maxVisitorsInLocation
  #     vistior = new Visitor(beacons, liveMode.maxSecondsPerBeacon)
  #     visitor.enter()
  #
  # Visitors.find().observe(
  #   'added': (doc) -> spawn()
  #   "removed": (oldDoc) ->
  #     console.log("Visitor exited and removed: #{JSON.stringify(oldDoc)}")
  #     spawn()
  # )

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
