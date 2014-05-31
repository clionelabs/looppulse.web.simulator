var simulationConfig = Meteor.settings;

var pendingEvents = [];

function addMilliseconds(date, ms) {
  return new Date(date + ms);
}

function dateToString(date) {
  return date;
}

function generateRangeEvent(visitor, path, beaconConfig) {
    var delay = path.delay;
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
      var event = generateRangeEvent(visitor, path, beaconConfig);
      event.delay += n * 10;
      events.push(event);
  });
  return events;
}

function generateEvents(visitor, path, beaconConfig) {
    var events = generateRangeEvents(visitor, path, beaconConfig);

    var delay = path.delay + path.duration;
    var exitedAt = addMilliseconds(startTime, delay);
    events.push({
      delay: delay,
      data: {
        "type": "didExitRegion",
        "uuid": beaconConfig.uuid,
        "major": beaconConfig.major,
        "minor": beaconConfig.minor,
        "visitor_uuid": visitor.uuid,
        "created_at": dateToString(exitedAt)
      }
    });

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

pendingEvents.forEach(function(event) {
  setTimeout(function() {
    console.log("event: " + Date.now() + JSON.stringify(event));
    firebase.push(event.data);
  }, event.delay);
});
