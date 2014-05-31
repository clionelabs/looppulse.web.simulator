var simulationConfig = Meteor.settings;

_.each(simulationConfig.visitors, function(visitor, key) {
    visitor.encounters.forEach(function(encounter) {
      var beaconConfig = simulationConfig.beacons[encounter.beacon];
      generateEvents(visitor, encounter, beaconConfig);
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
