generateEvents = function(visitor, path, beaconConfig) {
  setTimeout(function() {
    generateRangeEvents(visitor, path, beaconConfig);
    generateExitEvent(visitor, path, beaconConfig);
  }, path.delay);
}

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
  }, path.duration);
}
