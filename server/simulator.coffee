class Simulator
  constructor: (simulationConfig) ->
    @config = simulationConfig

  setupFirebase: (fbPath) ->
    firebase = new Firebase(fbPath)
    if @config.removeOldData
      firebase.remove()
      console.log("[Sim] Removed old data on: " + fbPath)

      console.log("[Sim] Writing simulated events to: " + fbPath)

    Events.find().observe({
      'added': (doc) ->
        firebase.push(doc, (error) ->
          if error
            console.log("[Firebase] Error: " + error + ",\n while simulating event: " + doc)
          else
            console.log("[Firebase] Published event: ", JSON.stringify(doc))
        )
    })

  logViewedEngagementEvents: (message) ->
    if !@engagementEventsRef
      return

    createdAt = new Date()
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

      setTimeout ->
        simulator.logViewedEngagementEvents(message)
        childSnapshot.ref().remove()
        console.log("[Sim] Message[%s] has been read", message._id)
      , delayMilliseconds

@Simulator = Simulator
