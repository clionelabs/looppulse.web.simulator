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
    Visitors.upsert({uuid: @uuid}, {
      uuid: @uuid
      state: @state
    })
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

  revisited: () =>
    @state = "revisited"
    beacon = Random.pickOne(@entrances)
    @stay(beacon)

  remove: () =>
    Visitors.remove({uuid: @uuid})

  stay: (beacon) =>
    # We could pass in rangeTillExit in the constructor but maybe we should
    # just let Encounter to read it from the global setting file.
    rangeTillExit = Meteor.settings.rangeTillExit
    duration = 1000 * Random.seconds(@secondsPerBeacon.min,
                                     @secondsPerBeacon.max)

    if beacon
      encounter = new Encounter(this, beacon, duration, rangeTillExit)
      encounter.simulate()

    # Since we don't have teleporter yet, there should be a delay between beacons.
    travelTime = 1000 * Random.seconds(@secondsBetweenBeacons.min,
                                       @secondsBetweenBeacons.max)
    interval = duration + travelTime
    setTimeout((=> @nextMove()), interval)
    @save()

    if beacon
      console.info("[Sim] Visitor[uuid:#{@uuid}] #{@state} for #{duration/1000} seconds at #{beacon.uuid}, #{beacon.major}, #{beacon.minor}.")

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
        [@revisited, @remove]
      when "revisited"
        [@browse, @exit]


@Visitor = Visitor
