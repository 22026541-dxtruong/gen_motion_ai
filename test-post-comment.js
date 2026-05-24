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
    
    // First get a post
    https.get('https://api.neuragen.xyz/posts', (res2) => {
      let data2 = '';
      res2.on('data', chunk => data2 += chunk);
      res2.on('end', () => {
        const posts = JSON.parse(data2);
        const postId = posts[0].id;
        
        // Now post a comment
        const req3 = https.request(`https://api.neuragen.xyz/posts/${postId}/comments`, {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
          }
        }, (res3) => {
          let data3 = '';
          res3.on('data', chunk => data3 += chunk);
          res3.on('end', () => {
            console.log("Comment:", data3);
          });
        });
        req3.write(JSON.stringify({ content: "test comment" }));
        req3.end();
      });
    });
  });
});
req.write(JSON.stringify({ email, password: "password123" }));
req.end();
