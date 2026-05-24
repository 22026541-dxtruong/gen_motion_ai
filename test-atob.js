function isTokenValid(token) {
  if (!token) return false;
  try {
    const base64Url = token.split('.')[1];
    if (!base64Url) return false;
    
    let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    // We didn't pad it. Let's see if Node's atob works without padding.
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );

    const payload = JSON.parse(jsonPayload);
    return payload.exp * 1000 > Date.now() + 5000;
  } catch (e) {
    console.error(e);
    return false;
  }
}

// Generate a dummy JWT payload
const payload = { exp: Math.floor(Date.now() / 1000) + 10000 };
const str = JSON.stringify(payload);
const b64 = Buffer.from(str).toString('base64').replace(/=/g, ''); // remove padding
const token = 'header.' + b64 + '.signature';

console.log('Result:', isTokenValid(token));
