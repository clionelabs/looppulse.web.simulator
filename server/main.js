var simulationConfig = Meteor.settings;

_.each(simulationConfig.Visitors, function(visitor, key) {
    visitor.Paths.forEach(function(path) {
      var beaconConfig = simulationConfig.Beacons[path.beacon];
      generateEvents(visitor, path, beaconConfig);
    });
  }
);

firebase = new Firebase(simulationConfig.Firebase);
if (simulationConfig.ForceReset) {
  firebase.remove();
}

Events.find().observe({
  'added': function(doc) {
    firebase.push(doc);
  }
});
