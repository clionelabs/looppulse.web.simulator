Simulator = function(beaconEventURL, beacons) {
  this.beaconEventURL = beaconEventURL;
  this.beacons = beacons;
}

Simulator.prototype.start = function() {
  console.log("[Simulator] Starting simulator: ", this.beaconEventURL, this.beacons);
};
