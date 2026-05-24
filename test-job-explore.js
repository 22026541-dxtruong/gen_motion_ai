const https = require('https');

https.get('https://api.neuragen.xyz/explore/trending', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const json = JSON.parse(data);
    const posts = json.data;
    if (!posts || !posts.length) return console.log("No posts");
    const post = posts.find(p => p.assetVersion && p.assetVersion.asset && p.assetVersion.asset.job);
    if (!post) return console.log("No job found in explore");
    const jobId = post.assetVersion.asset.job.id;
    console.log("Found Job ID:", jobId);
    
    https.get(`https://api.neuragen.xyz/jobs/${jobId}`, (res2) => {
      let data2 = '';
      res2.on('data', chunk => data2 += chunk);
      res2.on('end', () => {
        console.log("Job:", data2);
      });
    });
  });
});
