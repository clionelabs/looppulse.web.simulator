class FixedDebugSimulator extends @Simulator
  constructor: (config) ->
    super config

    fbPath = @config.firebase.root + @config.firebase.path
    @setupFirebase(fbPath)

  runOnce: ->
    for key, visitor of @config.visitors
      for encounterConfig in visitor.encounters
        beacon = @config.beacons[encounterConfig.beacon]
        duration = encounterConfig.durationInSeconds * 1000
        delay = encounterConfig.delayInSeconds * 1000

        encounter = new Encounter(visitor, beacon, duration, @config.rangeTillExit)
        encounter.simulate(delay)

    console.log("[Sim] Scheduled all encounters.")

  run: ->
    if @config.loopingIntervalInSeconds
      simulator = @
      do (simulator) ->
          setInterval ->
            simulator.runOnce()
          , simulator.config.loopingIntervalInSeconds * 1000

    @runOnce()

@FixedDebugSimulator = FixedDebugSimulator
