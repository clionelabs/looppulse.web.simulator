@Visitors = new Meteor.Collection(null)

class Visitor
  constructor: (beacons, strategies) ->
    @entrances = beacons.entrances
    @products = beacons.products
    @browseStrategy = strategies.browseStrategy
    @stayProductDurationStrategy = strategies.stayProductDurationStrategy
    @stayGeneralDurationStrategy = strategies.stayGeneralDurationStrategy
    @travelDurationStrategy = strategies.travelDurationStrategy
    @revisitDurationStrategy = strategies.revisitDurationStrategy
    @type = strategies.visitorType
    @uuid = Random.uuid()

  save: () ->
    Visitors.upsert({uuid: @uuid}, {
      uuid: @uuid
      state: @state
    })
    @_id = Visitors.findOne({uuid:@uuid})._id

  identify: () ->
    external_id = @type + ' ' + @uuid
    event = new IdentifyVisitorEvent(@uuid, external_id)
    event.save()

  enter: () =>
    @identify()

    @state = "entered"
    beacon = Random.pickOne(@entrances)
    duration = @stayGeneralDurationStrategy()
    @stay(beacon, duration)

  browse: () =>
    @state = "browsed"
    beacon = @browseStrategy()
    duration = @stayProductDurationStrategy()
    @stay(beacon, duration)

  exit: () =>
    @state = "exited"
    beacon = Random.pickOne(@entrances)
    duration = @stayGeneralDurationStrategy()
    @stay(beacon, duration)

  revisit: () =>
    @state = "revisiting"
    duration = @revisitDurationStrategy()
    setTimeout((=> @nextMove()), duration)
    @save()
    console.info("[Sim] Visitor[uuid:#{@uuid}] #{@state} in #{duration}.")
    properties = {revisitingInDays: duration/1000/3600, exitedAt:(new Date()).toString()}
    event = new TagVisitorEvent(@uuid, properties)
    event.save()

  remove: () =>
    Visitors.remove({uuid: @uuid})

  stay: (beacon, beaconDuration) =>
    duration = beaconDuration

    if beacon
      encounter = new Encounter(this, beacon, duration)
      encounter.simulate()

    # Since we don't have teleporter yet, there should be a delay between beacons.
    travelTime = @travelDurationStrategy()

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
        [@browse, @exit]
      when "exited"
        [@revisit, @remove]
      when "revisiting"
        [@enter]


@Visitor = Visitor
