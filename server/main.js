var simulationConfig = Meteor.settings;
var fbPath = simulationConfig.firebase.root + simulationConfig.firebase.path;
firebase = new Firebase(fbPath);
if (simulationConfig.removeOldData) {
  firebase.remove();
  console.log("[Sim] Removed old data on: " + fbPath);
}
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

if (simulationConfig.liveMode) {
  simulateLiveMode(simulationConfig);
} else {
  simulate(simulationConfig);
}
