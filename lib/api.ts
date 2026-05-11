import { cookies } from 'next/headers';
import { buildApiUrl } from '@/lib/runtime-config';

export async function fetchApi(endpoint: string, options: RequestInit = {}) {
  const cookieStore = await cookies();
  const token = cookieStore.get('accessToken')?.value;

  const headers = new Headers(options.headers);
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  if (!headers.has('Content-Type') && !(options.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }

  let res = await fetch(buildApiUrl(endpoint), {
    ...options,
    headers,
  });

  // Since we now proactively refresh tokens in middleware.ts, 
  // any 401 here means the token is truly invalid or refresh failed.

  if (!res.ok) {
    const errText = await res.text().catch(() => '');
    let errorBody: any = {};
    try {
      if (errText.trim()) errorBody = JSON.parse(errText);
    } catch {
      // Body is not valid JSON — use raw text as message
    }
    let msg = errorBody.message;
    if (Array.isArray(msg)) msg = msg.join(', ');
    throw new Error(msg || errText.trim() || `API Error: ${res.status}`);
  }

  // Handle empty / non-JSON responses safely
  const text = await res.text();
  const trimmed = text.trim();
  if (!trimmed) return null;
  try {
    return JSON.parse(trimmed);
  } catch {
    // Response is not valid JSON — return raw text
    return trimmed;
  }
}
