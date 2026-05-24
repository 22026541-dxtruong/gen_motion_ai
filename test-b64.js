const b64Url = "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ"; // missing padding
const base64 = b64Url.replace(/-/g, '+').replace(/_/g, '/');
console.log(Buffer.from(base64, 'base64').toString());
// Now with atob (Node 16+ has it globally)
try {
  console.log(atob(base64));
} catch(e) {
  console.log("atob failed:", e.message);
}
// Now pad it
let padded = base64;
while(padded.length % 4) padded += '=';
try {
  console.log("Padded atob:", atob(padded));
} catch(e) {
  console.log("Padded atob failed:", e.message);
}
