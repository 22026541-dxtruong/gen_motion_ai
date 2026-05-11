# Deploy `gen_motion_ai` to Vercel

This frontend is ready to deploy on Vercel as a standalone Next.js project.

## Project settings

- Framework Preset: `Next.js`
- Root Directory: `gen_motion_ai`
- Install Command: `npm install`
- Build Command: `npm run build`
- Output Directory: leave empty
- Node.js Version: `22.x`

## Required environment variables

Set these in Vercel for both `Production` and `Preview` unless you intentionally want different values:

```env
NEXT_PUBLIC_API_URL=https://api.neura.xyz
NEXT_PUBLIC_SITE_URL=https://neura.xyz
```

## Domain setup

- Production domain: `neura.xyz`
- Optional redirect/alias: `www.neura.xyz`

If you add both domains in Vercel, pick one canonical domain and redirect the other to it.

## Backend dependencies that must already match

The backend on Railway should already allow:

- `FRONTEND_URL=https://neura.xyz`
- `CORS_ORIGINS` including `https://neura.xyz`
- `OAUTH_ALLOWED_REDIRECT_URIS` including `https://neura.xyz/google/callback`
- `PAYOS_RETURN_URL=https://neura.xyz/billing/payos-return`
- `PAYOS_CANCEL_URL=https://neura.xyz/billing/payos-return`

## Smoke test after deploy

1. Open `https://neura.xyz/login`
2. Test email login
3. Test Google login
4. Test forgot password and reset password
5. Open billing and verify PayOS redirect returns to `/billing/payos-return`
6. Create a video job and confirm SSE updates still work

## Notes

- Vercel should import the repo as a monorepo project and point the Root Directory to `gen_motion_ai`.
- The frontend uses `proxy.ts` for auth cookie refresh on Next.js 16.
- `npm run build` already passes locally with this configuration.
