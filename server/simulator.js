Simulator = function(beaconEventURL, pois, simulationRules) {
  this.beaconEventURL = beaconEventURL;
  this.pois = pois;
  this.simulationRules = simulationRules;

  this.genVisitorsIntervalHandler = null;
  this.observeBeaconEventsHandler = null;

  this.beaconEventRef = new Firebase(this.beaconEventURL);
}

Simulator.prototype.start = function() {
  var self = this;
  self._observeBeaconEvents();

  self.genVisitorsIntervalHandler = setInterval(function() {
    var period = self._getCurrentPeriod();
    // console.log("[Simulator] ", period, Visitors.findCurrent().count());
    if (Visitors.findCurrent().count() < period.maxVisitors) {
      var visitor = Visitors.create(period.visitorBehaviour, self.pois);
      visitor.enter();
    }
  }, 1000);
}

Simulator.prototype.stop = function() {
  var self = this;
  clearInterval(self.genVisitorsIntervalHandler);
  // self.observeBeaconEventsHandler.stop();
}

Simulator.prototype._getCurrentPeriod = function() {
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

Simulator.prototype._observeBeaconEvents = function() {
  var self = this;
  self.observeBeaconEventsHandler = BeaconEvents.find().observe({
    'added': function(beaconEvent) {
      if (Settings.logging.showSimulatorEvents) {
        console.log("[Simulator] new beacon event: ", JSON.stringify(beaconEvent));
      }
      var doc = {
          uuid: beaconEvent.beacon.uuid,
          major: beaconEvent.beacon.major,
          minor: beaconEvent.beacon.minor,
          type: beaconEvent.type,
          visitor_uuid: beaconEvent.visitorUUID,
          created_at: beaconEvent.createdAt
      };
      self.beaconEventRef.push(doc, function(error) {
        if (error) {
          console.error('[Simulator] Error pushing beacon events: ', JSON.stringify(beaconEvent), ', error: ', error);
        }
        beaconEvent.remove(); 
      });
    }
  });
}
