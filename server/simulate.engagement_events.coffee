logViewedEvent = (message, firebaseURL) ->
  engagementEventsRef = new Firebase(firebaseURL)
  createdAt = new Date();
  data = {
    created_at: createdAt.toISOString()
    type: "didReceiveRemoteNotification"
    message_id: message._id
  }
  engagementEventsRef.push(data)


engagementEventsFirebaseURL = (companyId) ->
  if companyId
    return "#{Meteor.settings.firebase.root}/companies/#{companyId}/engagement_events"
  else
    return "#{Meteor.settings.firebase.root}/engagement_events"


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
      logViewedEvent(message, engagementEventsFirebaseURL(Meteor.settings.companyId))
      childSnapshot.ref().remove()
      console.log("[Sim] Message[%s] has been read", message._id)
    , delayMilliseconds
