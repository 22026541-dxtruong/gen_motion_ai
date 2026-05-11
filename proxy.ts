import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { buildApiUrl } from '@/lib/runtime-config';

function isTokenValid(token: string | undefined) {
  if (!token) return false;
  try {
    const base64Url = token.split('.')[1];
    if (!base64Url) return false;
    
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );

    const payload = JSON.parse(jsonPayload);
    // Add 5 seconds buffer
    return payload.exp * 1000 > Date.now() + 5000;
  } catch (e) {
    return false;
  }
}

export async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const accessToken = request.cookies.get('accessToken')?.value;
  const refreshToken = request.cookies.get('refreshToken')?.value;
  
  const hasValidAccess = isTokenValid(accessToken);
  const hasValidRefresh = isTokenValid(refreshToken);
  
  let newAccessToken = accessToken;
  let newRefreshToken = refreshToken;
  let didRefresh = false;

  // Proactively refresh token if access is expired but refresh is valid
  if (!hasValidAccess && hasValidRefresh && refreshToken) {
    try {
      const refreshRes = await fetch(buildApiUrl('/auth/refresh'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      
      if (refreshRes.ok) {
        const data = await refreshRes.json();
        newAccessToken = data.accessToken;
        if (data.refreshToken) {
          newRefreshToken = data.refreshToken;
        }
        didRefresh = true;
      } else {
        // Refresh failed (e.g. revoked)
        newAccessToken = undefined;
        newRefreshToken = undefined;
      }
    } catch (e) {
      newAccessToken = undefined;
      newRefreshToken = undefined;
    }
  }

  const isAuthenticated = isTokenValid(newAccessToken) || isTokenValid(newRefreshToken);

  const authRoutes = ['/login', '/register'];
  const privateRoutes = ['/create']; // /explore is public
  
  // Forward the new cookies to the next request (Server Components)
  const requestHeaders = new Headers(request.headers);
  if (didRefresh) {
    if (newAccessToken) request.cookies.set('accessToken', newAccessToken);
    if (newRefreshToken) request.cookies.set('refreshToken', newRefreshToken);
    
    // Build cookie string from modified request.cookies
    const cookieHeader = request.cookies.getAll().map(c => `${c.name}=${c.value}`).join('; ');
    requestHeaders.set('cookie', cookieHeader);
  }

  // Nếu chưa đăng nhập mà cố vào các trang yêu cầu đăng nhập, chuyển về trang /login
  const isPrivateRoute = privateRoutes.some(route => pathname.startsWith(route));
  if (!isAuthenticated && isPrivateRoute) {
    const response = NextResponse.redirect(new URL('/login', request.url));
    // Clear dead cookies to break the infinite redirect loop
    if (accessToken) response.cookies.delete('accessToken');
    if (refreshToken) response.cookies.delete('refreshToken');
    return response;
  }

  // Nếu truy cập trang auth (như /login) với cookie hỏng, dọn dẹp cookie đó
  if (!isAuthenticated && authRoutes.includes(pathname) && (accessToken || refreshToken)) {
    const response = NextResponse.next({
      request: { headers: requestHeaders },
    });
    if (accessToken) response.cookies.delete('accessToken');
    if (refreshToken) response.cookies.delete('refreshToken');
    return response;
  }

  const response = NextResponse.next({
    request: { headers: requestHeaders },
  });

  // Set new cookies for the browser
  if (didRefresh && newAccessToken) {
    response.cookies.set('accessToken', newAccessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 7, // 1 week
    });
    if (newRefreshToken) {
      response.cookies.set('refreshToken', newRefreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 30, // 30 days
      });
    }
  }

  return response;
}

export const config = {
  matcher: ['/login', '/register', '/explore', '/create', '/'],
};
