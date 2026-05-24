const https = require('https');

https.get('https://api.neuragen.xyz/posts', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const posts = JSON.parse(data);
    const postId = posts[0].id;
    
    // Auth login
    const req = https.request('https://api.neuragen.xyz/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (resAuth) => {
      let dataAuth = '';
      resAuth.on('data', chunk => dataAuth += chunk);
      resAuth.on('end', () => {
        const json = JSON.parse(dataAuth);
        const token = json.accessToken;
        
        // Get comments
        https.get(`https://api.neuragen.xyz/posts/${postId}/comments`, {
          headers: { 'Authorization': 'Bearer ' + token }
        }, (res3) => {
          let data3 = '';
          res3.on('data', chunk => data3 += chunk);
          res3.on('end', () => {
            console.log("Comments response:", data3);
          });
        });
      });
    });
    // Register earlier created user
    req.write(JSON.stringify({ email: "test1779637238806@example.com", password: "password123" }));
    req.end();
  });
});
