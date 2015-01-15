Authenticator = {};

Authenticator.auth = function(authURL, authToken) {
  result = HTTP.post(authURL, {
    data: {
      capture: {
        visitorUUID: Random.uuid(),
        sdk: '0.0',
        device: 'simulator'
      }
    },
    headers: {
      'x-auth-token': authToken
    }
  })
  console.log("Authenticated with", authURL, JSON.stringify(result));
  return result.data;
}
