class FixedDebugSimulator
  constructor: (simulationConfig) ->
    @simulationConfig = simulationConfig

  run: ->
    for key, visitor of @simulationConfig.visitors
      for encounterConfig in visitor.encounters
        beacon = @simulationConfig.beacons[encounterConfig.beacon]
        duration = encounterConfig.durationInSeconds * 1000
        delay = encounterConfig.delayInSeconds * 1000

        encounter = new Encounter(visitor, beacon, duration, @simulationConfig.rangeTillExit)
        encounter.simulate(delay)

    console.log("[Sim] Scheduled all encounters.")

@simulateFixedDebugMode = (config) ->
  simulator = new FixedDebugSimulator config

  if config.loopingIntervalInSeconds
    do(simulator) ->
      setInterval ->
        simulator.run()
      , config.loopingIntervalInSeconds * 1000

  simulator.run()
