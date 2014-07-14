// Main program
var simulationConfig = Meteor.settings;
var fbPath = simulationConfig.firebase.root + simulationConfig.firebase.path;
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

//Setup mode
if (simulationConfig.liveMode) {
  console.info("[Sim] Using Live Mode")
  simulateLiveMode(simulationConfig);
} else {
  console.info("[Sim] Using Normal Mode")
  simulate(simulationConfig);
}
