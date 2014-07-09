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
        } else {
          console.log("[Firebase] OK: ", doc._id, doc.type, doc.created_at, doc.uuid, doc.major);
        }
      }
    );
  }
});

//Config check
if(simulationConfig.loopingIntervalInSeconds <= 0){ console.warn("[Sim] Delay between Encounters is too small! \n Please check `Meteor.settings.loopingIntervalInSeconds`") }

//Setup mode
if (simulationConfig.liveMode) {
  console.info("[Sim] Using Live Mode")
  simulateLiveMode(simulationConfig);
} else {
  console.info("[Sim] Using Normal Mode")
  simulate(simulationConfig);
}
