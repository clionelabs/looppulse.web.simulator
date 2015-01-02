BeaconEvents = new Meteor.Collection(null, {
  transform: function(doc) {
    return new BeaconEvent(doc);
  }
});

BeaconEvents.create = function(beacon, visitorUUID, type) {
  var event = new BeaconEvent({beacon: beacon, visitorUUID: visitorUUID, type: type, createdAt: Clock.getNow().format()}); 
  event.save();
}

/**
 * @property {Object} beacon {uuid: xxx, major: yyy, minor: zzz}
 * @property {String} visitorUUID
 * @property {String} type [didEnterRegion|didExitRegion]
 * @property {Date} createdAt
 *
 */
BeaconEvent = function(doc) {
  _.extend(this, doc); 
}

BeaconEvent.prototype.save = function() {
  var self = this;
  var selector = {_id: self._id};
  var modifier = {
    $set: {
      beacon: self.beacon,
      visitorUUID: self.visitorUUID,
      type: self.type,
      createdAt: self.createdAt
    }
  }
  var result = BeaconEvents.upsert(selector, modifier);
  if (result.insertedId) {
    self._id = result.insertedId;
  }
  return self._id;
};

BeaconEvent.prototype.remove = function() {
  BeaconEvents.remove({_id: this._id});
}
