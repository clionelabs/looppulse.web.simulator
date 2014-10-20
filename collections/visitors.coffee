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

  authenticate: () =>
    authUrl = Meteor.settings.application.authURL
    result = HTTP.post(authUrl, {
      data: {
        session: {
          visitorUUID: @uuid,
          sdk: '0.0',
          device: 'simulator'
        }
      },
      headers: {
        'x-auth-token': Meteor.settings.application.token
      }
    })

    # TODO: save session ID to be used for sending beacon events
    # console.log("Authenticated with", authURL, JSON.stringify(result))
    @rootFbPath = result.data.system.firebase.root
    # @beaconEventsFbPath = result.data.system.firebase.beacon_events
    # @engagementEventsFbPath = result.data.system.firebase.engagement_events
    @visitorEventsFbPath = result.data.system.firebase.visitor_events

    firebaseRef = new Firebase(@rootFbPath)
    firebaseRef.auth result.data.system.firebase.token, (error, result) =>
      if error
        console.error('Login Failed!', @rootFbPath, error)
      else
        console.info('Authenticated successfully with payload:', result.auth)
        console.info('Auth expires at:', new Date(result.expires * 1000))
        @identify()

  identify: () =>
    doc = {
      type: "identify",
      visitor_uuid: @uuid,
      external_id: @type + ' ' + @uuid
    }
    console.warn('identify', doc)
    firebaseRef = new Firebase(@visitorEventsFbPath)
    firebaseRef.push(doc)

  enter: () =>
    @authenticate()

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
