var simulationConfig = Meteor.settings;

var pendingEvents = [];

function addMilliseconds(date, ms) {
  return new Date(date + ms);
}

function dateToString(date) {
  return date.toString();
}

function generateRangeEvent(visitor, path, beaconConfig, extra_delay) {
  var extra_delay = extra_delay || 0;
  var delay = path.delay + extra_delay;
  var enteredAt = addMilliseconds(startTime, delay);
  var pendingEvents = [];
  return {
      delay: delay,
      data: {
        "type": "didRangeBeacons",
        "uuid": beaconConfig.uuid,
        "major": beaconConfig.major,
        "minor": beaconConfig.minor,
        "visitor_uuid": visitor.uuid,
        "created_at": dateToString(enteredAt)
      }
  };
}

function generateRangeEvents(visitor, path, beaconConfig) {
  var events = [];
  _(5).times(function (n) {
      var event = generateRangeEvent(visitor, path, beaconConfig, n * 1000);
      events.push(event);
  });
  return events;
}

function generateExitEvent(visitor, path, beaconConfig) {
  var delay = path.delay + path.duration;
  var exitedAt = addMilliseconds(startTime, delay);
  return {
    delay: delay,
    data: {
      "type": "didExitRegion",
      "uuid": beaconConfig.uuid,
      "major": beaconConfig.major,
      "minor": beaconConfig.minor,
      "visitor_uuid": visitor.uuid,
      "created_at": dateToString(exitedAt)
    }
  };
}

function generateEvents(visitor, path, beaconConfig) {
    var events = generateRangeEvents(visitor, path, beaconConfig);
    events.push(generateExitEvent(visitor, path, beaconConfig));
    return events;
}

var startTime = Date.now();

_.each(simulationConfig.Visitors, function(visitor, key) {
    visitor.Paths.forEach(function(path) {
      var beaconConfig = simulationConfig.Beacons[path.beacon];
      pendingEvents = pendingEvents.concat(generateEvents(visitor, path, beaconConfig));
    });
  }
);

console.log("count: " + pendingEvents.length);

firebase = new Firebase(simulationConfig.Firebase);
if (simulationConfig.ForceReset) {
  firebase.remove();
}

pendingEvents.forEach(function(event) {
  setTimeout(function() {
    console.log("event: " + Date.now() + JSON.stringify(event));
    firebase.push(event.data);
  }, event.delay);
});
