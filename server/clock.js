Clock = {
  virtualStartTime: null,
  realStartTime: null,
  timezone: null,
  speed: null,

  init: function(startTimeDeltaInSeconds, timezone, speed) {
    this.virtualStartTime = moment().zone(timezone).add(startTimeDeltaInSeconds, 's');
    this.realStartTime = moment();
    this.timezone = timezone;
    this.speed = speed;
    console.log("[Clock] Simulator clock starts at: ", this.virtualStartTime.format(), ", with speed: ", this.speed);
  },

  checkIsInit: function() {
    if (this.virtualStartTime === null) throw "[Clock] Simulator clock is not yet initialized";
  },

  getNow: function() {
    this.checkIsInit();
    return moment(this.virtualStartTime).add(moment().diff(this.realStartTime) * this.speed);
  },

  setTimeout: function(func, ms) {
    this.checkIsInit();
    return setTimeout(func, ms/this.speed);
  },

  setInterval: function(func, ms) {
    this.checkIsInit();
    return setInterval(func, ms/this.speed);
  }
}
