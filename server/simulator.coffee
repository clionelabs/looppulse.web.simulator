class Simulator
  constructor: (simulationConfig) ->
    @simClock = SimClock.get()
    @config = simulationConfig

  setupFirebase: (beaconEventFirebasePath, visitorEventFirebasePath) ->
    firebase = new Firebase(beaconEventFirebasePath)
    if @config.removeOldData
      firebase.remove()
      console.log("[Sim] Removed old data on: " + beaconEventFirebasePath)

      console.log("[Sim] Writing simulated events to: " + beaconEventFirebasePath)

    Events.find().observe({
      'added': (doc) ->
        # FIXME make sure doc.session_id is set
        firebase.push(doc, (error) ->
          if error
            console.log("[Firebase] Error: " + error + ",\n while simulating event: " + doc)
          else
            console.log("[Firebase] Published event: ", JSON.stringify(doc))
          # We have to remove the event once processed because the
          # Events.upsert() will eventually cause a serious back log.
          # Another solution is to index the Events collection but that
          # would require it to be turned into a persistent colleciotn
          Events.remove({_id: doc._id})
        )
    })

    if visitorEventFirebasePath
      visitorFB = new Firebase(visitorEventFirebasePath)
      VisitorEvents.find().observe({
        'added': (doc) ->
          visitorFB.push(doc, (error) ->
            if error
              console.log("[Firebase] Error: " + error + ",\n while simulating event: " + doc)
            else
              console.log("[Firebase] Published event: ", JSON.stringify(doc))
            # We have to remove the event once processed because the
            # Events.upsert() will eventually cause a serious back log.
            # Another solution is to index the Events collection but that
            # would require it to be turned into a persistent colleciotn
            VisitorEvents.remove({_id: doc._id})
            )
        })


  logViewedEngagementEvents: (message) ->
    if !@engagementEventsRef
      return

    createdAt = @simClock.getNow()
    data = {
      created_at: createdAt.toISOString()
      type: "didReceiveRemoteNotification"
      message_id: message._id
    }
    @engagementEventsRef.push(data)

  setupEngagementSimulation: (fbPath) ->
    if !@config.engagementEvents
      return

    engagementConfig = @config.engagementEvents
    @engagementEventsRef = new Firebase(fbPath)

    simulator = @

    messagesRef = new Firebase(engagementConfig.firebaseURL.deliveringMessages)
    messagesRef.on 'child_added', (childSnapshot, prevChildName) ->
      message = childSnapshot.val()

      if engagementConfig.lostMessageRatio and Random.trueInRatio(engagementConfig.lostMessageRatio)
        console.log("[Sim] Message[%s] lost", message._id)
        childSnapshot.ref().remove()
        return

      delayMilliseconds = 1000 * Random.seconds(engagementConfig.secondsBeforeViewed.min, engagementConfig.secondsBeforeViewed.max)

      @simClock.setTimeout ->
        simulator.logViewedEngagementEvents(message)
        childSnapshot.ref().remove()
        console.log("[Sim] Message[%s] has been read", message._id)
      , delayMilliseconds

@Simulator = Simulator
