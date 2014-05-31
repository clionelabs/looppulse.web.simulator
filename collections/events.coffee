@Events = new Meteor.Collection(null)

addMilliseconds = (date, ms) ->
  return new Date(date + ms)

dateToString = (date) ->
  return date.toString()

class Event
  constructor: (visitor, path, beacon) ->
    @uuid = beacon.uuid;
    @major = beacon.major;
    @minor = beacon.minor;
    @visitor_uuid = visitor.uuid;
    @created_at = dateToString(new Date())

  save: ->
    Events.upsert(this, this)


class RangeEvent extends Event
  constructor: (visitor, path, beacon) ->
    super(visitor, path, beacon)
    @type = "didRangeBeacons"

class ExitEvent extends Event
  constructor: (visitor, path, beacon) ->
    super(visitor, path, beacon)
    @type = "didExitRegion"


@RangeEvent = RangeEvent
@ExitEvent = ExitEvent
