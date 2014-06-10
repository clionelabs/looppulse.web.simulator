var simulationConfig = Meteor.settings;
var fbPath = simulationConfig.firebase.root + simulationConfig.firebase.path;
firebase = new Firebase(fbPath);
if (simulationConfig.forceReset) {
  firebase.remove();
  console.log("Reseted data on: " + fbPath);
}
console.log("Writing simulated events to: " + fbPath);

_.each(simulationConfig.visitors, function(visitor, key) {
    visitor.encounters.forEach(function(encounterConfig) {
      var beacon = simulationConfig.beacons[encounterConfig.beacon];
      var duration = encounterConfig.durationInSeconds * 1000;
      var delay = encounterConfig.delayInSeconds * 1000;

      var encounter = new Encounter(visitor, beacon, duration);
      encounter.simulate(delay);
    });
  }
);
console.log("Scheduled all encounters.");


Events.find().observe({
  'added': function(doc) {
    firebase.push(doc,
      function(error) {
        if (error) {
          console.log("Error ()" + JSON.stringify(error) + ") while simulating event: " + JSON.stringify(doc));
        } else {
          console.log("Succeed simulating event: " + JSON.stringify(doc));
        }
      }
    );
  }
});
