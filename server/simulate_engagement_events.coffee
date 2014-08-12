logViewedEvent = (message, firebaseURL) ->
  engagementEventsRef = new Firebase(firebaseURL)
  createdAt = new Date();
  data = {
    created_at: createdAt.toISOString()
    engagement_id: message.engagementId
    type: "didReceiveRemoteNotification"
    visitor_uuid: message.visitorId,
    message_id: message._id
  }
  engagementEventsRef.push(data)

@simulateEngagementEvents = (config) ->
  messagesRef = new Firebase(config.firebaseURL.deliveringMessages)
  messagesRef.on 'child_added', (childSnapshot, prevChildName) ->
    message = childSnapshot.val()

    if config.lostMessageRatio and Random.trueInRatio(config.lostMessageRatio)
      console.log("[Sim] Message[%s] lost", message._id)
      childSnapshot.ref().remove()
      return

    delayMilliseconds = 1000 * Random.seconds(config.secondsBeforeViewed.min, config.secondsBeforeViewed.max)
    setTimeout ->
      logViewedEvent(message, config.firebaseURL.engagementEvents)
      childSnapshot.ref().remove()
      console.log("[Sim] Message[%s] has been read", message._id)
    , delayMilliseconds
