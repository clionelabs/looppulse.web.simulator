/**
 * Server (default) settings
 */
Settings = {
  timezone: "+08:00",
  speed: 1,
  startTimeBeforeNowInSeconds: 0,

  application: {
    authURL: null,
    token: null
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
