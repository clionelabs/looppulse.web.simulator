simulationConfig = Meteor.settings

switch simulationConfig.simulationMode
  when 'fixed_debug'
    new @FixedDebugSimulator(simulationConfig).run()
  when 'continuous_debug'
    new @ContinuousDebugSimulator(simulationConfig).run()
  when 'continuous_live'
    new @ContinuousLiveSimulator(simulationConfig).run()


