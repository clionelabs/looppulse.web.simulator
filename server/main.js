var simulationConfig = Meteor.settings;

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

firebase = new Firebase(simulationConfig.firebase);
if (simulationConfig.forceReset) {
  firebase.remove();
}

Events.find().observe({
  'added': function(doc) {
    firebase.push(doc);
  }
});
