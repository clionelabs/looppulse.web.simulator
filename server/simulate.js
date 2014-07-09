simulate = function(simulationConfig) {
  if (simulationConfig.loopingIntervalInSeconds) {
      console.log("[Sim] Looping every " + simulationConfig.loopingIntervalInSeconds + " seconds.");
  }

  var main = function(){
    console.log("[Sim] Cycle Begin.");
    _.each(simulationConfig.visitors, function(visitor, key) {
        visitor.encounters.forEach(function(encounterConfig) {
          var beacon = simulationConfig.beacons[encounterConfig.beacon];
          var duration = encounterConfig.durationInSeconds * 1000;
          var delay = encounterConfig.delayInSeconds * 1000;

          var encounter = new Encounter(visitor, beacon, duration, simulationConfig.rangeTillExit);
          encounter.simulate(delay);
        });
      }
    );
    console.log("[Sim] Scheduled all encounters.");
  }

  if (simulationConfig.loopingIntervalInSeconds) {
    setInterval(main, simulationConfig.loopingIntervalInSeconds * 1000); // in ms
  }

  main();
}
