const https = require('https');

const req = https.request('https://api.neuragen.xyz/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const json = JSON.parse(data);
    console.log("Login res:", Object.keys(json));
    const token = json.accessToken;
    const refreshToken = json.refreshToken;
    
    if (!refreshToken) return console.log("No refresh token returned by login");
    
    const reqRefresh = https.request('https://api.neuragen.xyz/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (resRefresh) => {
      let rData = '';
      resRefresh.on('data', chunk => rData += chunk);
      resRefresh.on('end', () => {
        console.log("Refresh res status:", resRefresh.statusCode);
        console.log("Refresh res data:", rData);
      });
    });
    reqRefresh.write(JSON.stringify({ refreshToken }));
    reqRefresh.end();
  });
});
req.write(JSON.stringify({ email: "test1779637238806@example.com", password: "password123" }));
req.end();
