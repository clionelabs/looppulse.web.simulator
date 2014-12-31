Random = {
  uuid: function() {
    var objectID = new Meteor.Collection.ObjectID();
    return objectID.toHexString();
  },

  gaussian: function(mean, sigma) {
    var s;
    while (!s || s >= 1) {
      var u = 2 * Math.random() - 1;
      var v = 2 * Math.random() - 1;
      s = u * u + v * v;
    }
    var w = Math.sqrt(-2 * Math.log(s) / 2);
    var z = u * w;
    console.log(s, Math.log(s), -2 * Math.log(s));
    return mean + z * sigma;
  }
};
