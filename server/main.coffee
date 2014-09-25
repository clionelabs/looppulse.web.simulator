# TODO move Firebase auth. logic to simulator?
firebaseUrl = Meteor.settings.firebase.root or Meteor.settings.firebase.config
firebaseSecret = Meteor.settings.firebase.rootSecret or Meteor.settings.firebase.configSecret

firebaseRef = new Firebase(firebaseUrl)
firebaseRef.auth firebaseSecret, Meteor.bindEnvironment (error, result) ->
  if error
    console.error('Login Failed!', error)
  else
    console.info('Authenticated successfully with payload:', result.auth)
    console.info('Auth expires at:', new Date(result.expires * 1000))
    do startSimulation


startSimulation = ->
  simulationConfig = Meteor.settings

  switch simulationConfig.simulationMode
    when 'fixed_debug'
      new @FixedDebugSimulator(simulationConfig).run()
    when 'continuous_debug'
      new @ContinuousDebugSimulator(simulationConfig).run()
    when 'continuous_live'
      new @ContinuousLiveSimulator(simulationConfig).run()
