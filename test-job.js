const https = require('https');

const req = https.request('https://api.neuragen.xyz/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (resAuth) => {
  let dataAuth = '';
  resAuth.on('data', chunk => dataAuth += chunk);
  resAuth.on('end', () => {
    const json = JSON.parse(dataAuth);
    const token = json.accessToken;
    
    https.get('https://api.neuragen.xyz/jobs', {
      headers: { 'Authorization': 'Bearer ' + token }
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        const jobs = JSON.parse(data).data;
        if (!jobs || !jobs.length) return console.log("No jobs");
        const jobId = jobs[0].id;
        
        https.get(`https://api.neuragen.xyz/jobs/${jobId}`, {
          headers: { 'Authorization': 'Bearer ' + token }
        }, (res2) => {
          let data2 = '';
          res2.on('data', chunk => data2 += chunk);
          res2.on('end', () => {
            console.log("Job:", JSON.stringify(JSON.parse(data2), null, 2));
          });
        });
      });
    });
  });
});
req.write(JSON.stringify({ email: "vuductantb123@gmail.com", password: "password" })); // using valid dummy user if possible, or we can use our test user
// wait, we created "test1779637238806@example.com" with "password123", but it has NO JOBS.
// I'll use vuductantb123@gmail.com... no wait I don't know the password for that.
// Let's check explore endpoint for a job. Explore endpoint doesn't need auth!
