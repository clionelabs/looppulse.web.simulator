# Implements a virtual clock for the simulator, which supports:
#   1) current time
#   2) speed (faster/slower than normal)
#
# A typical use case of the virtual clock would be: fake the simulator time as 1 month before now, and make it move x1000 speed (i.e. 3.6 seconds = 1 hr)
#   Then you will have generated the events for the past month in less than an hour. 
#
# Caveat: the virtual clock cloud theoretically go beyond the actual real current time. In this case, the simulator will still functino properly,
#         but the application dashboard *might* have some weird behaviour. 
#
# In code level, it currently supports three functions:
#   1) getNow() -> get current virtual time
#   2) setTimeout() -> simulate the ordinary javascript setTimeout function, but adjusted accordingly to speed
#   3) setInteral() -> simulate the orindary javascript setInterval function, but adjusted accordingly to speed
#
class SimClock

  instance = null # Singleton

  class PrivateSimClock
    constructor: ->
      @startTime = null
      @clockStartedTime = null
      @timezone = null
      @speed = null

    # @param startTimeBeforeNowInSeconds {Number} Start time of clock X seconds before now
    # @param timezone {String} timezone, e.g. +08:00
    # @param speed {Number} clock speed relative to normal. e.g. 2 = x2 speed
    init: (startTimeBeforeNowInSeconds, timezone, speed) ->
      @startTime = moment().zone(timezone).subtract(startTimeBeforeNowInSeconds, 's')
      @clockStartedTime = moment()
      @timezone = timezone
      @speed = speed
      console.log("[SimClock] init with started time: ", @startTime.format() + ", speed: " + @speed)

    getNow: ->
      if (@clockStartedTime == null)
        console.error("[SimClock] not initialized") 
        return null
      return moment(@startTime).add(moment().diff(@clockStartedTime) * @speed)

    setTimeout: (func, ms) ->
      if (@clockStartedTime== null)
        console.error("[SimClock] not initialized") 
        return null

      return setTimeout(func, ms/@speed)

    setInterval: (func, ms) -> 
      if (@clockStartedTime == null)
        console.error("[SimClock] not initialized") 
        return null
      return setInterval(func, ms/@speed)

  @get: ->
    instance ?= new PrivateSimClock()
    return instance
@SimClock = SimClock
