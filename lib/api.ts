import { cookies } from 'next/headers';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

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

  let res = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
  });

  // Auto-refresh token if 401 Unauthorized
  if (!res.ok && res.status === 401) {
    const refreshToken = cookieStore.get('refreshToken')?.value;
    
    if (refreshToken) {
      // Attempt to get a new token pair
      const refreshRes = await fetch(`${API_URL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });

      if (refreshRes.ok) {
        const data = await refreshRes.json();
        
        // Update the cookies with the new tokens
        cookieStore.set('accessToken', data.accessToken, {
          httpOnly: true,
          secure: process.env.NODE_ENV === 'production',
          sameSite: 'lax',
          path: '/',
          maxAge: 60 * 60 * 24 * 7, // 1 week
        });
        
        if (data.refreshToken) {
          cookieStore.set('refreshToken', data.refreshToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'lax',
            path: '/',
            maxAge: 60 * 60 * 24 * 30, // 30 days
          });
        }

        // Retry the original request with the new access token
        headers.set('Authorization', `Bearer ${data.accessToken}`);
        res = await fetch(`${API_URL}${endpoint}`, {
          ...options,
          headers,
        });
      }
    }
  }

  if (!res.ok) {
    const errorBody = await res.json().catch(() => ({}));
    let msg = errorBody.message;
    if (Array.isArray(msg)) msg = msg.join(', ');
    throw new Error(msg || `API Error: ${res.status}`);
  }

  // Handle empty responses
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}
