var simulationConfig = Meteor.settings;

_.each(simulationConfig.visitors, function(visitor, key) {
    visitor.encounters.forEach(function(encounter) {
      var beacon = simulationConfig.beacons[encounter.beacon];
      generateEvents(visitor, encounter, beacon);
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
