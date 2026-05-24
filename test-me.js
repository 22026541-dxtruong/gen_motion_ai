const https = require('https');

const email = "test" + Date.now() + "@example.com";
const req = https.request('https://api.neuragen.xyz/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const json = JSON.parse(data);
    const token = json.accessToken;
    if (!token) return console.log("No token:", json);
    
    https.get('https://api.neuragen.xyz/users/me', {
      headers: { 'Authorization': 'Bearer ' + token }
    }, (res2) => {
      let data2 = '';
      res2.on('data', chunk => data2 += chunk);
      res2.on('end', () => {
        console.log("Me:", data2);
      });
    });
  });
});
req.write(JSON.stringify({ email, password: "password123" }));
req.end();
