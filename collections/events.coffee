@Events = new Meteor.Collection()

addMilliseconds = (date, ms) ->
  return new Date(date + ms)

dateToString = (date) ->
  return date.toString()

class Event
  constructor: (visitor, path, beaconConfig) ->
    @uuid = beaconConfig.uuid;
    @major = beaconConfig.major;
    @minor = beaconConfig.minor;
    @visitor_uuid = visitor.uuid;
    @created_at = dateToString(new Date())

class RangeEvent extends Event
  constructor: (visitor, path, beaconConfig) ->
    super(visitor, path, beaconConfig)
    @type = "didRangeBeacons"

class ExitEvent extends Event
  constructor: (visitor, path, beaconConfig) ->
    super(visitor, path, beaconConfig)
    @type = "didExitRegion"
