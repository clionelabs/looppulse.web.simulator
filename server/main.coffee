# TODO move Firebase auth. logic to simulator?
firebaseUrl = Meteor.settings.firebase.root or Meteor.settings.firebase.config
firebaseSecret = Meteor.settings.firebase.rootSecret or Meteor.settings.firebase.configSecret

firebaseRef = new Firebase(firebaseUrl)
firebaseRef.auth firebaseSecret, Meteor.bindEnvironment (error, result) ->
  if error
    console.error('Login Failed!', firebaseUrl, error)
  else
    console.info('Authenticated successfully with payload:', result.auth)
    console.info('Auth expires at:', new Date(result.expires * 1000))
    do startSimulation


startSimulation = ->
  simulationConfig = Meteor.settings

  timezone = if Meteor.settings.timezone != undefined then Meteor.settings.timezone else "+08:00" # default GMT+8
  speed = if Meteor.settings.speed != undefined then Meteor.settings.speed else 1 # default speed = x1
  startTimeBeforeNowInSeconds = if Meteor.settings.startTimeBeforeNowInSeconds != undefined then Meteor.settings.startTimeBeforeNowInSeconds else 0 # default current time
  SimClock.get().init(startTimeBeforeNowInSeconds, timezone, speed)

  switch simulationConfig.simulationMode
    when 'fixed_debug'
      new @FixedDebugSimulator(simulationConfig).run()
    when 'continuous_debug'
      new @ContinuousDebugSimulator(simulationConfig).run()
    when 'continuous_live'
      new @ContinuousLiveSimulator(simulationConfig).run()
