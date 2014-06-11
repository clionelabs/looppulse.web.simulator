class Encounter
  constructor: (visitor, beacon, duration, rangeTillExit) ->
    @visitor = visitor
    @beacon = beacon
    @duration = duration
    @rangeTillExit = rangeTillExit

  simulate: (delay) ->
    setTimeout((=> @simulateEvents()), delay)

  simulateEvents: ->
    @simulateRangeEvents()
    @simulateExitEvent()

  simulateRangeEvents: ->
    simulateOneRangeEvent = =>
      event = new RangeEvent(@visitor, @beacon)
      event.save()

    # Determine the duration for the range events
    rangeDurationInSeconds = 5;
    if (@rangeTillExit)
      rangeDurationInSeconds = (@duration - 1000)/1000;

    _(rangeDurationInSeconds).times(
      (n) -> setTimeout((=> simulateOneRangeEvent()), n * 1000)
    )

  simulateExitEvent: ->
    simulateOneExitEvent = =>
      event = new ExitEvent(@visitor, @beacon)
      event.save()

    setTimeout((=> simulateOneExitEvent()), @duration)


@Encounter = Encounter
