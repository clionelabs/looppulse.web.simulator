/**
 * Server (default) settings
 */
Settings = {
  timezone: "+08:00",
  speed: 1,
  startTimeDeltaInSecs: 0,

  application: {
    authURL: null,
    token: null
  },

  simulationRules: {
    day: [
      {
        startMin: 0,
        endMin: 1440,
        maxVisitor: 5,
        visitorBehaviour: {
          browseDurationInSecs: {mean: 10, std: 2},
          pLeaving: 0.1 // probability leaving after browsing a poi
        }
      }
    ]
  },

  logging: {
    showVisitorAction: true,
    showSimulatorEvents: true,
  }
};

Settings.load = function(customSettings) {
  _.extend(Settings, customSettings);

  // Required fields:
  if (Settings.application.authURL === null) {
    console.error("[Settings] Missing application.authUrl");
  }
  if (Settings.application.token === null) {
    console.error("[Settings] Missing application.token");
  }
}
