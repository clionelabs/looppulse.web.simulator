generateEvents = function(visitor, path, beacon) {
  setTimeout(function() {
    generateRangeEvents(visitor, path, beacon);
    generateExitEvent(visitor, path, beacon);
  }, path.delay);
}

function generateRangeEvent(visitor, path, beacon) {
  var event = new RangeEvent(visitor, path, beacon);
  event.save();
}

function generateRangeEvents(visitor, path, beacon) {
  _(5).times(function (n) {
    setTimeout(function() {
      generateRangeEvent(visitor, path, beacon)
    }, n * 1000);
  });
}

function generateExitEvent(visitor, path, beacon) {
  setTimeout(function() {
    var event = new ExitEvent(visitor, path, beacon);
    event.save();
  }, path.duration);
}
