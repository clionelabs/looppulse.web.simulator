Simulator = function(beaconEventURL, beacons, simulationRules) {
  this.beaconEventURL = beaconEventURL;
  this.beacons = beacons;
  this.simulationRules = simulationRules;
}

Simulator.prototype.getCurrentPeriod = function() {
  var currentTime = Clock.getNow();
  var currentMinuteOfDay = parseInt(currentTime.format('m')) + 60 * parseInt(currentTime.format('H'))

  var currentPeriod = null;
  _.each(this.simulationRules.day, function(period) {
    if (currentMinuteOfDay >= period.startMin && currentMinuteOfDay <= period.endMin) {
      currentPeriod = period;
    }
  });
  return currentPeriod;
}

Simulator.prototype.start = function() {
  var self = this;
  console.log("[Simulator] Starting simulator: ", this.beaconEventURL, this.beacons);
  Clock.init(Settings.startTimeDeltaInSeconds, Settings.timezone, Settings.speed);

  setInterval(function() {
    var period = self.getCurrentPeriod();
    // console.log("[Simulator] ", period, Visitors.findCurrent().count());
    if (Visitors.findCurrent().count() < period.maxVisitors) {
      var visitor = new Visitor();
      visitor.enter();
    }
  }, 1000);
};
