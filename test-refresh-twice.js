const https = require('https');

const req = https.request('https://api.neuragen.xyz/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const json = JSON.parse(data);
    const refreshToken = json.refreshToken;
    
    // First refresh
    const reqRefresh = https.request('https://api.neuragen.xyz/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (resRefresh) => {
      let rData = '';
      resRefresh.on('data', chunk => rData += chunk);
      resRefresh.on('end', () => {
        console.log("First refresh status:", resRefresh.statusCode);
        const newRefreshToken = JSON.parse(rData).refreshToken;
        
        // Second refresh with OLD token
        const reqRefresh2 = https.request('https://api.neuragen.xyz/auth/refresh', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        }, (resRefresh2) => {
          console.log("Second refresh (old token) status:", resRefresh2.statusCode);
        });
        reqRefresh2.write(JSON.stringify({ refreshToken }));
        reqRefresh2.end();
        
      });
    });
    reqRefresh.write(JSON.stringify({ refreshToken }));
    reqRefresh.end();
  });
});
req.write(JSON.stringify({ email: "test1779637238806@example.com", password: "password123" }));
req.end();
