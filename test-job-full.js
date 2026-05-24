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
    
    // Top up credits
    const reqTopup = https.request('https://api.neuragen.xyz/users/me/credits/topup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
    }, (resTopup) => {
      
      // Create a job
      const reqJob = https.request('https://api.neuragen.xyz/jobs/video', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
      }, (resJob) => {
        let jobData = '';
        resJob.on('data', chunk => jobData += chunk);
        resJob.on('end', () => {
          const job = JSON.parse(jobData);
          console.log("Created Job:", job);
          
          if (!job.id) return;
          
          // Get the job
          setTimeout(() => {
            https.get(`https://api.neuragen.xyz/jobs/${job.id}`, {
              headers: { 'Authorization': 'Bearer ' + token }
            }, (resGet) => {
              let getData = '';
              resGet.on('data', chunk => getData += chunk);
              resGet.on('end', () => {
                console.log("Fetched Job:", getData);
              });
            });
          }, 2000);
        });
      });
      reqJob.write(JSON.stringify({ prompt: "test video", presetId: "3df73ee4-abdb-4cd5-a083-d95b28a8d132" })); // preset id?
      reqJob.end();
    });
    reqTopup.write(JSON.stringify({ amount: 1000 }));
    reqTopup.end();
  });
});
req.write(JSON.stringify({ email: "test1779637238806@example.com", password: "password123" }));
req.end();
