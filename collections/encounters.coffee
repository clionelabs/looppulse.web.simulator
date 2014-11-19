class Encounter
  constructor: (visitor, beacon, duration) ->
    @simClock = SimClock.get()
    @visitor = visitor
    @beacon = beacon
    @duration = duration
    @rangeTillExit = Meteor.settings.rangeTillExit
    @skipRangeEvents = Meteor.settings.skipRangeEvents

  simulate: (delay=100) ->
    console.warn("[Encounter] Delay is too small! Use > 0 delay.") if (delay <= 0)
    @simClock.setTimeout((=> @simulateEvents()), delay)

  simulateEvents: ->
    @simulateEnterEvent()
    #@simulateRangeEvents()
    @simulateExitEvent()

  simulateEnterEvent: ->
    event = new EnterEvent(@visitor, @beacon)
    event.save()

  simulateRangeEvents: ->
    return if @skipRangeEvents

    simulateOneRangeEvent = =>
      console.log("[Encounters] simulateOneRangeEvent")
      event = new RangeEvent(@visitor, @beacon)
      event.save()

    simulateAllRangeEvents = =>
      # background processing allowed by iOS after iBeacon detection
      allowableRangingDurationInSeconds = 5
      # first second is didEnterEvent
      rangeDurationInSeconds = allowableRangingDurationInSeconds - 1
      if (@rangeTillExit || @duration < rangeDurationInSeconds * 1000)
        # -1 second for exit event
        rangeDurationInSeconds = (@duration - 1000)/1000
        rangeDurationInSeconds = 0 if rangeDurationInSeconds < 0

      simClock = @simClock
      _(rangeDurationInSeconds).times(
        (n) -> simClock.setTimeout((=> simulateOneRangeEvent()), n * 1000)
      )

    # Delay all didRangeRegion events by 1 seconds as the first event
    # should be didEnterEvent
    @simClock.setTimeout((=> simulateAllRangeEvents()), 1000)

  simulateExitEvent: ->
    simulateOneExitEvent = =>
      event = new ExitEvent(@visitor, @beacon)
      event.save()

    @simClock.setTimeout((=> simulateOneExitEvent()), @duration)


@Encounter = Encounter
