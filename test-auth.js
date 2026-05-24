const https = require('https');

// Send an empty refresh token to see the error, and maybe deduce the structure
const req = https.request('https://api.neuragen.xyz/auth/refresh', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log("Status:", res.statusCode);
    console.log("Response:", data);
  });
});
req.write(JSON.stringify({ refreshToken: "invalid" }));
req.end();
