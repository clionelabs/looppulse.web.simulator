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


class RangeEvent extends Event
  constructor: (visitor, beacon) ->
    super(visitor, beacon)
    @type = "didRangeBeacons"


class ExitEvent extends Event
  constructor: (visitor, beacon) ->
    super(visitor, beacon)
    @type = "didExitRegion"


dateToString = (date) ->
  return date.toString()

@RangeEvent = RangeEvent
@ExitEvent = ExitEvent
