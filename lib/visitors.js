Visitors = new Meteor.Collection(null, {
  transform: function(doc) {
    return new Visitor(doc);
  }
});

Visitors.findCurrent = function() {
  return Visitors.find({state: {$ne: 'left'}});
}

Visitors.create = function(behaviour, pois) {
  var visitor = new Visitor({uuid: Random.uuid(), behaviour: behaviour, pois: pois});
  visitor.save();
  return visitor;
}

/**
 * @property {String} uuid
 * @property {Object} behaviour
 * @property {Object[]} pois Array of pois {name: xxx, beacon: {uuid: xxx, major: yyy, minor: zzz}}
 * @property {String} state
 */
Visitor = function(doc) {
  _.extend(this, doc);
}

Visitor.prototype.save = function() {
  var self = this;
  var selector = {_id: self._id};
  var modifier = {
    $set: {
      uuid: self.uuid,
      behaviour: self.behaviour,
      pois: self.pois,
      state: self.state
    }
  }
  var result = Visitors.upsert(selector, modifier);
  if (result.insertedId) {
    self._id = result.insertedId;
  }
  return self._id;
};

Visitor.prototype.enter = function() {
  this.updateState("entering");
  this.nextMove();
}

Visitor.prototype.browse = function() {
  var self = this;
  var time = 1000 * Random.gaussian(self.behaviour.browseDurationInSecs.mean, self.behaviour.browseDurationInSecs.std);
  if (Settings.logging.showVisitorAction) {
    console.log("[Visitor] ", this.uuid, " - Browsing. Taking: ", time, "ms");
  }
  this.updateState("browsing");

  var pickedPoi = Random.pickOne(this.pois);
  BeaconEvents.create(pickedPoi.beacon, self.uuid, 'didEnterRegion');
  Clock.setTimeout(function() {
    BeaconEvents.create(pickedPoi.beacon, self.uuid, 'didExitRegion');
    self.nextMove();
  }, time);
}

Visitor.prototype.exit = function() {
  this.updateState("exiting");
  this.nextMove();
}

Visitor.prototype.left = function() {
  this.updateState("left");
}

Visitor.prototype.updateState = function(state) {
  if (Settings.logging.showVisitorAction) {
    console.log("[Visitor] ", this.uuid, " - From ", this.state, " to ", state);
  }
  this.state = state;
  this.save();
}

Visitor.prototype.nextMove = function() {
  if (this.state === 'entering') {
    this.browse();
  } else if (this.state === 'browsing') {
    var pickedChoice = Random.pickOneWithWeights([this.behaviour.pLeaving, 1-this.behaviour.pLeaving], ['left', 'browse']);
    if (pickedChoice === 'left') {
      this.exit();
    } else {
      this.browse();
    }
  } else if (this.state === 'exiting') {
    this.left();
  }
}
