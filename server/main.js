// Override default settings
Settings.load(Meteor.settings);

// Setup simulator virtual clock
Clock.init(Settings.startTimeDeltaInSecs, Settings.timezone, Settings.speed);

// Authenticate application server
var result = Authenticator.auth(Settings.application.authURL, Settings.application.token);
if (result.authenticated) {
  var simulator = new Simulator(result.captureId, result.system.firebase, result.system.pois, Settings.simulationRules);
  simulator.start();

  /*
  setTimeout(function() {
    simulator.stop();
  }, 10000);
  */
} else {
  console.log("Authentication Failed");
}
