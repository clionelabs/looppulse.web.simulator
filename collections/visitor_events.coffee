@VisitorEvents = new Meteor.Collection(null)

class VisitorEvent
  constructor: (uuid) ->
    @visitor_uuid = uuid

  save: ->
    VisitorEvents.upsert(this, this)

class IdentifyVisitorEvent extends VisitorEvent
  constructor: (uuid, external_id) ->
    super(uuid)
    @type = "identify"
    @external_id = external_id

class TagVisitorEvent extends VisitorEvent
  constructor: (uuid, properties) ->
    super(uuid)
    @type = "tag"
    @properties = properties

@VisitorEvent = VisitorEvent
@IdentifyVisitorEvent = IdentifyVisitorEvent
@TagVisitorEvent = TagVisitorEvent
