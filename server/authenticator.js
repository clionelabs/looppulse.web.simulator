Authenticator = {};

Authenticator.auth = function(authURL, authToken) {
  result = HTTP.post(authURL, {
    data: {
      session: {
        visitorUUID: '17dba1647591d871707bef5f',  // FIXME genertate this
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
