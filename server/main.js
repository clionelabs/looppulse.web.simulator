var simulationConfig = Meteor.settings;

_.each(simulationConfig.visitors, function(visitor, key) {
    visitor.encounters.forEach(function(encounterConfig) {
      var beacon = simulationConfig.beacons[encounterConfig.beacon];
      var encounter = new Encounter(visitor,
                                    beacon,
                                    encounterConfig.duration);
      encounter.simulate(encounterConfig.delay);
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
