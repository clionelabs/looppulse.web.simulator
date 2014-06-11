var simulationConfig = Meteor.settings;
var fbPath = simulationConfig.firebase.root + simulationConfig.firebase.path;
firebase = new Firebase(fbPath);
if (simulationConfig.forceReset) {
  firebase.remove();
  console.log("[Sim] Reseted data on: " + fbPath);
}
console.log("[Sim] Writing simulated events to: " + fbPath);

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

Events.find().observe({
  'added': function(doc) {
    firebase.push(doc,
      function(error) {
        if (error) {
          console.log("[Firebase] Error: " + error + ",\n while simulating event: " + doc);
        } else {
          console.log("[Firebase] OK: ", doc._id, doc.created_at, doc.uuid);
        }
      }
    );
  }
});

if (simulationConfig.looping) {
  setInterval(main, simulationConfig.loopingInterval) // in ms
}


main();