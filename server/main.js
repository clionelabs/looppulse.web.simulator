var simulationConfig = Meteor.settings;

firebase = new Firebase(simulationConfig.Firebase);

if (simulationConfig.ForceReset) {
  firebase.remove();
}

Events.find().observe({
  'added': function(doc) {
    firebase.push(doc);
  }
});

function generateRangeEvent(visitor, path, beaconConfig) {
  var event = new RangeEvent(visitor, path, beaconConfig);
  event.save();
}

function generateRangeEvents(visitor, path, beaconConfig) {
  _(5).times(function (n) {
    setTimeout(function() {
      generateRangeEvent(visitor, path, beaconConfig)
    }, n * 1000);
  });
}

function generateExitEvent(visitor, path, beaconConfig) {
  setTimeout(function() {
      var event = new ExitEvent(visitor, path, beaconConfig);
      event.save();
  }, path.delay + path.duration);
}

function generateEvents(visitor, path, beaconConfig) {
    generateRangeEvents(visitor, path, beaconConfig);
    generateExitEvent(visitor, path, beaconConfig);
}

_.each(simulationConfig.Visitors, function(visitor, key) {
    visitor.Paths.forEach(function(path) {
      var beaconConfig = simulationConfig.Beacons[path.beacon];
      generateEvents(visitor, path, beaconConfig);
    });
  }
);
