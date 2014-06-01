class Encounter
  constructor: (visitor, beacon, duration) ->
    @visitor = visitor
    @beacon = beacon
    @duration = duration

  simulate: (delay) ->
    setTimeout((=> @simulateEvents()), delay)

  simulateEvents: ->
    @simulateRangeEvents()
    @simulateExitEvent()

  simulateRangeEvents: ->
    simulateOneRangeEvent = =>
      event = new RangeEvent(@visitor, @beacon)
      event.save()

    _(5).times(
      (n) -> setTimeout((=> simulateOneRangeEvent()), n * 1000)
    )

  simulateExitEvent: ->
    simulateOneExitEvent = =>
      event = new ExitEvent(@visitor, @beacon)
      event.save()

    setTimeout((=> simulateOneExitEvent()), @duration)

@Encounter = Encounter
