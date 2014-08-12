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

@Random = Random
