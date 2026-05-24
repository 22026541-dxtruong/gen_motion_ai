const https = require('https');

https.get('https://api.neuragen.xyz/posts', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const posts = JSON.parse(data);
    const postId = posts[0].id;
    console.log("Post ID:", postId);
    
    https.get(`https://api.neuragen.xyz/posts/${postId}/comments`, (res2) => {
      let data2 = '';
      res2.on('data', chunk => data2 += chunk);
      res2.on('end', () => {
        console.log("Comments:", data2);
      });
    });
  });
});
