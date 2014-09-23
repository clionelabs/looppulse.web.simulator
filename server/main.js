var setupFirebase = function(fbPath, simulationConfig) {
  firebase = new Firebase(fbPath);
  if (simulationConfig.removeOldData) {
    firebase.remove();
    console.log("[Sim] Removed old data on: " + fbPath);
  }

  //Setup Firebase
  console.log("[Sim] Writing simulated events to: " + fbPath);
  Events.find().observe({
    'added': function(doc) {
      firebase.push(doc,
        function(error) {
          if (error) {
            console.log("[Firebase] Error: " + error + ",\n while simulating event: " + doc);
          }
        }
      );
    }
  });
}

var setupEngagement = function(simulationConfig) {
  if (simulationConfig.engagementEvents) {
    simulateEngagementEvents(simulationConfig.engagementEvents);
  }
}

var simulationConfig = Meteor.settings;
switch (simulationConfig.simulationMode) {
  case "continuous_live":
    var authUrl = simulationConfig.application.authURL;
    var result = HTTP.get(authUrl, {
      headers: {
        "x-auth-token": simulationConfig.application.token
      }
    });
    console.log("Authenticated with", JSON.stringify(result));
    var fbPath = result.data.system.firebase.beacon_events;
    setupFirebase(fbPath, simulationConfig)
    simulateContinuousLiveMode(simulationConfig);
    setupEngagement(simulationConfig)
    break;

  case "continuous_debug":
    var fbPath = simulationConfig.firebase.root + simulationConfig.firebase.path;
    setupFirebase(fbPath, simulationConfig)
    simulateContinuousDebugMode(simulationConfig)
    setupEngagement(simulationConfig)
    break;

  case "fixed_debug":
    var fbPath = simulationConfig.firebase.root + simulationConfig.firebase.path;
    setupFirebase(fbPath, simulationConfig)
    simulateFixedDebugMode(simulationConfig)
    break;

  default:
    console.error("invalid simulation mode");
}
