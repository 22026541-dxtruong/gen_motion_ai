const https = require('https');

const req = https.request('https://api.neuragen.xyz/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log("Status:", res.statusCode);
    const json = JSON.parse(data);
    console.log("Refresh token:", json.refreshToken);
  });
});
// Let's see if we can trigger an error and maybe it still sends tokens? No.
// We need a test account. The user has email: "test@example.com"?
req.write(JSON.stringify({ email: "vuductantb123@gmail.com", password: "password" }));
req.end();
