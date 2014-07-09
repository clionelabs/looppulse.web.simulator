@Visitors = new Meteor.Collection(null)

class Visitor
  constructor: (beacons, secondsPerBeacon, secondsBetweenBeacons) ->
    @entrances = beacons.entrances
    @products = beacons.products
    @cashiers = beacons.cashiers
    @secondsPerBeacon = secondsPerBeacon
    @secondsBetweenBeacons = secondsBetweenBeacons
    @uuid = Random.uuid()

  save: () ->
    Visitors.upsert({uuid: @uuid}, {uuid: @uuid})
    @_id = Visitors.findOne({uuid:@uuid})._id

  enter: () =>
    @state = "entered"
    beacon = Random.pickOne(@entrances)
    @stay(beacon)

  browse: () =>
    @state = "browsed"
    beacon = Random.pickOne(@products)
    @stay(beacon)

  purchase: () =>
    @state = "purchased"
    beacon = Random.pickOne(@cashiers)
    @stay(beacon)

  exit: () =>
    @state = "exited"
    beacon = Random.pickOne(@entrances)
    @stay(beacon)

  remove: () =>
    Visitors.remove({uuid: @uuid})

  stay: (beacon) =>
    # We could pass in rangeTillExit in the constructor but maybe we should
    # just let Encounter to read it from the global setting file.
    rangeTillExit = Meteor.settings.rangeTillExit
    delay = Meteor.settings.loopingIntervalInSeconds

    duration = 1000 * Random.seconds(@secondsPerBeacon.min,
                                     @secondsPerBeacon.max)
    encounter = new Encounter(this, beacon, duration, rangeTillExit)
    encounter.simulate(delay)

    # Since we don't have teleporter yet, there should be a delay between beacons.
    travelTime = 1000 * Random.seconds(@secondsBetweenBeacons.min,
                                       @secondsBetweenBeacons.max)
    interval = duration + travelTime
    setTimeout((=> @nextMove()), interval)
    @save()
    console.log("[Visitor] Visitor Scheduled")

    console.log("\t uuid:#{@uuid}\n\t_id:#{@_id}")
    console.log("\t #{@state} for #{duration/1000} seconds \n\tat #{beacon.uuid}, #{beacon.major}, #{beacon.minor}")
    console.log("\t delay: #{delay}, interval: #{interval}")
    # console.log("[Sim] Visitor[uuid:#{@uuid}, _id:#{@_id}] will take #{travelTime/1000} seconds to move to next destination")

  nextMove: () =>
    possible = @possibleNextMoves()
    next = Random.pickOne(possible)
    next()

  possibleNextMoves: () =>
    switch @state
      when "entered"
        [@browse, @exit]
      when "browsed"
        [@browse, @purchase, @exit]
      when "purchased"
        [@browse, @exit]
      when "exited"
        [@remove]


@Visitor = Visitor
