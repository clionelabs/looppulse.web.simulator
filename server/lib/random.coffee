class Random
  @seconds: (min, max) ->
    Math.floor(min + (max - min) * Math.random())

  @uuid: () ->
    objectID = new Meteor.Collection.ObjectID()
    objectID.toHexString()

  @pickOne: (choices) ->
    n = choices.length
    index = Math.floor(@seconds(0, n))
    # console.log("picked (#{index}) #{choices[index]} from #{choices}")
    choices[index]

  @trueInRatio: (ratio) ->
    # 0 <= ratio <= 1
    return Math.random() <= ratio

  @gaussian: (mean, sigma) ->
    until s and s < 1
      u = 2 * Math.random() - 1
      v = 2 * Math.random() - 1
      s = u * u + v * v
    w = Math.sqrt(-2 * Math.log(s) / s)
    z = u * w
    return mean + z * sigma

@Random = Random
