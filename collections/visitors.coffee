@Visitors = new Meteor.Collection(null)

class Visitor
  constructor: (beacons, maxSecondsPerBeacon) ->
    @entrances = beacons.entrances
    @products = beacons.products
    @cashiers = beacons.cashiers
    @maxSecondsPerBeacon = maxSecondsPerBeacon
    @uuid = Random.uuid()

  save: () ->
    Visitors.upsert(this, this)

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

    duration = 1000 * Random.seconds(1+@maxSecondsPerBeacon/10, @maxSecondsPerBeacon)
    encounter = new Encounter(this, beacon, duration, rangeTillExit)
    encounter.simulate()
    setTimeout((=> @nextMove()), duration)
    @save()

    console.log("#{@uuid} #{@state} for #{duration/1000} seconds at #{beacon.major}")

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
