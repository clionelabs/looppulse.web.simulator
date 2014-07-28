class Encounter
  constructor: (visitor, beacon, duration, rangeTillExit) ->
    @visitor = visitor
    @beacon = beacon
    @duration = duration
    @rangeTillExit = rangeTillExit

  simulate: (delay=100) ->
    console.warn("[Encounter] Delay is too small! Use > 0 delay.") if (delay <= 0)
    setTimeout((=> @simulateEvents()), delay)

  simulateEvents: ->
    @simulateEnterEvent()
    @simulateRangeEvents()
    @simulateExitEvent()

  simulateEnterEvent: ->
    event = new EnterEvent(@visitor, @beacon)
    event.save()

  simulateRangeEvents: ->
    simulateOneRangeEvent = =>
      event = new RangeEvent(@visitor, @beacon)
      event.save()

    # Determine the duration for the range events
    rangeDurationInSeconds = 5;
    if (@rangeTillExit || @duration < rangeDurationInSeconds * 1000)
      rangeDurationInSeconds = (@duration - 1000)/1000
      rangeDurationInSeconds = 0 if rangeDurationInSeconds < 0

    _(rangeDurationInSeconds).times(
      (n) -> setTimeout((=> simulateOneRangeEvent()), n * 1000)
    )

  simulateExitEvent: ->
    simulateOneExitEvent = =>
      event = new ExitEvent(@visitor, @beacon)
      event.save()

    setTimeout((=> simulateOneExitEvent()), @duration)


@Encounter = Encounter
