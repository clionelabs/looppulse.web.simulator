@Events = new Meteor.Collection(null)

class Event
  constructor: (visitor, beacon) ->
    @uuid = beacon.uuid
    @major = beacon.major
    @minor = beacon.minor
    @visitor_uuid = visitor.uuid
    @created_at = dateToString(new Date())

  save: ->
    Events.upsert(this, this)


class EnterEvent extends Event
  constructor: (visitor, beacon) ->
    super(visitor, beacon)
    @type = "didEnterRegion"


class RangeEvent extends Event
  constructor: (visitor, beacon) ->
    super(visitor, beacon)
    @type = "didRangeBeacons"

    @accuracy = Random.pickOne([2.617100534911419, 0.5, 3, 70])
    @proximity = Random.pickOne(["unknown", "far", "near", "intermediate"])
    @rssi = Random.pickOne([-98, -1, 1])

    if (!Meteor.settings.liveMode)
      @accuracy = 0.5
      @proximity = "intermediate"
      @rssi = 1

class ExitEvent extends Event
  constructor: (visitor, beacon) ->
    super(visitor, beacon)
    @type = "didExitRegion"


dateToString = (date) ->
  return date.toString()

@EnterEvent = EnterEvent
@RangeEvent = RangeEvent
@ExitEvent = ExitEvent
