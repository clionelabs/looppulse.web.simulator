/**
 * Server (default) settings
 */
Settings = {
  timezone: "+08:00",
  speed: 2,
  startTimeDeltaInSeconds: -10000,

  application: {
    authURL: null,
    token: null
  },

  simulationRules: {
    day: [
      {
        startMin: 0,
        endMin: 1440,
        maxVisitor: 10,
        browseDurationInSecs: {mean: 1000, std: 100}
      }
    ]
  },

  logging: {
    showVisitorAction: true
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
