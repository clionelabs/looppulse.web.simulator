looppulse.web.simulator
=======================

Simulator for beacon events. It is currently supporting three modes:

0. fixed_debug
  1. A fixed and deterministic visitors routines will be generated.
  2. It doesn't connect with manager application.
  3. Sample config file: `server/settings.fixed.debug.sample.json`

1. continuous_debug
  1. Visitors will be generated continuosly
  2. It doesn't connect with manager application.
  3. Sample config file: `server/settings.continuous.debug.sample.json`

2. continuous_live
  1. Visitors will be generated continuosly
  2. It connects with a manager application.
  3 Sample config file: `server/settings.continuous.live.sample.json`

To update config file:

0. fixed_debug
  1. `firebase` -> `root`: the firebase location receiving beacon_events generated by the simulator

1. continuous_debug
  1. `firebase` -> `root`: the firebase location receiving beacon_events/engagement_events generated by the simulator
  2. `engagementEvents` -> `firebaseURL`: the firebase location providing delivering_messages observed by the simulator

2. continuous_live
  1. `firebase` -> `config`: the firebase location providing beacon and product information.
  2. `application`: authentication path and token for the manager application.
  3. `engagementEvents` -> `firebaseURL`: the firebase location providing delivering_messages observed by the simulator
