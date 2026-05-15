const DEFAULT_LOCAL_API_URL = 'http://localhost:3000';
const DEFAULT_LOCAL_SITE_URL = 'http://localhost:5173';
const DEFAULT_PRODUCTION_API_URL = 'https://api.neuragen.xyz';
const DEFAULT_PRODUCTION_SITE_URL = 'https://neuragen.xyz';

function trimTrailingSlash(value: string) {
  return value.replace(/\/+$/, '');
}

function resolvePublicUrl(envValue: string | undefined, productionFallback: string, localFallback: string) {
  const value = envValue?.trim();
  if (value) {
    return trimTrailingSlash(value);
  }

  return process.env.NODE_ENV === 'production'
    ? productionFallback
    : localFallback;
}

export const apiBaseUrl = resolvePublicUrl(
  process.env.NEXT_PUBLIC_API_URL,
  DEFAULT_PRODUCTION_API_URL,
  DEFAULT_LOCAL_API_URL,
);

export const siteBaseUrl = resolvePublicUrl(
  process.env.NEXT_PUBLIC_SITE_URL,
  DEFAULT_PRODUCTION_SITE_URL,
  DEFAULT_LOCAL_SITE_URL,
);

export function buildApiUrl(path: string) {
  return `${apiBaseUrl}${path.startsWith('/') ? path : `/${path}`}`;
}

export function buildSiteUrl(path: string) {
  return `${siteBaseUrl}${path.startsWith('/') ? path : `/${path}`}`;
}

export type GoogleAuthIntent = 'login' | 'register';

export function buildGoogleAuthUrl(intent: GoogleAuthIntent = 'login') {
  const endpoint = intent === 'register' ? '/auth/google/register' : '/auth/google/login';
  const redirectUri = buildSiteUrl(`/google/callback?intent=${intent}`);
  return `${buildApiUrl(endpoint)}?platform=web&redirectUri=${encodeURIComponent(redirectUri)}`;
}
