// Override default settings
Settings.load(Meteor.settings);

var result = Authenticator.auth(Settings.application.authURL, Settings.application.token);
if (result.authenticate) {
  var simulator = new Simulator(result.beaconEventURL, result.beacons);
  simulator.start();
} else {
  console.log("Authentication Failed");
}

