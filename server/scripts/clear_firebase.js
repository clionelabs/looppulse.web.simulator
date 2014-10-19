if (!process.env.URL || !process.env.SECRET) {
  console.error("Require environment variables: URL='...' and SECRET='...'");
  return;
}

// npm install firebase --save
var Firebase = require("firebase");
var firebaseUrl = process.env.URL;
var firebaseSecret = process.env.SECRET;
var firebaseRef = new Firebase(firebaseUrl);
firebaseRef.authWithCustomToken(firebaseSecret, function(error, result){
    if (error) {
      console.error('Login Failed!', firebaseUrl, error)
    }
    else {
      console.info('Authenticated successfully');
      firebaseRef.remove();
      console.info('Removed content at: ', firebaseUrl);
      console.info('You can quit this app now.')
    }
  }
);
