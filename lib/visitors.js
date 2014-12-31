Visitors = new Meteor.Collection(null);

Visitors.findCurrent = function() {
  return Visitors.find({state: {$ne: 'left'}});
}

/**
 * @property {String} uuid
 * @property {String} state
 */
Visitor = function() {
  this.uuid = Random.uuid();
}

Visitor.prototype.save = function() {
  Visitors.upsert({uuid: this.uuid}, {
    uuid: this.uuid,
    state: this.state
  });
}

Visitor.prototype.enter = function() {
  var self = this;
  var time = Random.gaussian(1000, 1000);
  if (Settings.logging.showVisitorAction) {
    console.log("[Visitor] ", this.uuid, " - Entering. Taking: ", time, "ms");
  }
  this.updateState("entering");
  Clock.setTimeout(function() {self.nextMove()}, time);
}

Visitor.prototype.browse = function() {
  var self = this;
  var time = Random.gaussian(10000, 2000);
  if (Settings.logging.showVisitorAction) {
    console.log("[Visitor] ", this.uuid, " - Browsing. Taking: ", time, "ms");
  }
  this.updateState("browsing");
  Clock.setTimeout(function() {self.nextMove()}, time);
}

Visitor.prototype.exit = function() {
  var self = this;
  var time = Random.gaussian(1000, 1000);
  if (Settings.logging.showVisitorAction) {
    console.log("[Visitor] ", this.uuid, " - Exiting. Taking: ", time, "ms");
  }
  this.updateState("exiting");
  Clock.setTimeout(function() {self.nextMove()}, time);
}

Visitor.prototype.left = function() {
  if (Settings.logging.showVisitorAction) {
    console.log("[Visitor] ", this.uuid, " - Left");
  }
  this.updateState("left");
}

Visitor.prototype.updateState = function(state) {
  this.state = state;
  this.save();
}

Visitor.prototype.nextMove = function() {
  if (this.state === 'entering') {
    this.browse();
  } else if (this.state === 'browsing') {
    this.exit();
  } else if (this.state === 'exiting') {
    this.left();
  }
}
