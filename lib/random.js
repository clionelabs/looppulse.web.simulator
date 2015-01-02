Random = {
  /**
   * Generate a random Meteor ObjectID
   */
  uuid: function() {
    var objectID = new Meteor.Collection.ObjectID();
    return objectID.toHexString();
  },

  /**
   * Sample a gaussian distribution, with given mean and standard deviation
   */
  gaussian: function(mean, sigma) {
    var s;
    while (!s || s >= 1) {
      var u = 2 * Math.random() - 1;
      var v = 2 * Math.random() - 1;
      s = u * u + v * v;
    }
    var w = Math.sqrt(-2 * Math.log(s) / 2);
    var z = u * w;
    return mean + z * sigma;
  },

  /**
   *  Sample a uniform distribution between min and max
   */
  uniform: function(min, max) {
    return Math.floor(min + (max - min) * Math.random());
  }, 

  /**
   *  Pick a random element in an array, with each element having equal chances
   */
  pickOne: function(choices) {
    return choices[Math.floor(this.uniform(0, choices.length))];
  },

  /**
   * Pick a random element in an array, with each element having probability propotional to given weights.
   *
   * @param {Number[]} weights Array of numbers, with sum equal to 1.0. Each weight correspond to the element's probability
   */
  pickOneWithWeights: function(weights, choices) {
    var sum = 0;
    var rand = Math.random();
    for (var i = 0; i < weights.length; i++) {
      sum += weights[i];
      console.log("[Random] ", sum, weights, rand, choices[i]);
      if (rand < sum) return choices[i];
    }
    throw "sum of weights not equal to 1.0";
  }
};
