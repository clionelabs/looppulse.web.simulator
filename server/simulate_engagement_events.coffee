logViewedEvent = (message, firebaseURL) ->
  engagementEventsRef = new Firebase(firebaseURL)
  createdAt = new Date();
  data = {
    created_at: createdAt.toISOString()
    engagement_id: message.engagementId
    type: "didReceiveRemoteNotification"
    visitor_uuid: message.visitorId
  }
  engagementEventsRef.push(data)

@simulateEngagementEvents = (config) ->
  messagesRef = new Firebase(config.firebaseURL.deliveringMessages)
  messagesRef.on 'child_added', (childSnapshot, prevChildName) ->
    delayMilliseconds = Random.seconds(config.secondsBeforeViewed.min, config.secondsBeforeViewed.max)
    setTimeout ->
      message = childSnapshot.val()
      logViewedEvent(message, config.firebaseURL.engagementEvents)
      childSnapshot.ref().remove()
    , delayMilliseconds
