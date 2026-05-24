const https = require('https');

const req = https.request('https://api.neuragen.xyz/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const json = JSON.parse(data);
    const token = json.accessToken;
    
    https.get('https://api.neuragen.xyz/posts', (resExp) => {
      let d2 = '';
      resExp.on('data', c => d2 += c);
      resExp.on('end', () => {
        const posts = JSON.parse(d2).data;
        if (!posts || !posts.length) return console.log("no posts");
        const postId = posts[0].id;
        console.log("Found post id:", postId);
        
        const reqComment = https.request(`https://api.neuragen.xyz/posts/${postId}/comments`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
        }, (resC) => {
          let dc = '';
          resC.on('data', c => dc += c);
          resC.on('end', () => {
            console.log("Comment status:", resC.statusCode);
            console.log("Comment res:", dc);
          });
        });
        reqComment.write(JSON.stringify({ content: "Test extra field", postId })); // Sending postId
        reqComment.end();
      });
    });
  });
});
req.write(JSON.stringify({ email: "test1779637238806@example.com", password: "password123" }));
req.end();
