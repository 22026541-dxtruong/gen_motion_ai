import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

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

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const accessToken = request.cookies.get('accessToken')?.value;
  const refreshToken = request.cookies.get('refreshToken')?.value;
  
  const hasValidAccess = isTokenValid(accessToken);
  const hasValidRefresh = isTokenValid(refreshToken);
  
  // User is considered authenticated if either token is valid
  // (If access is expired but refresh is valid, API fetch will auto-refresh it)
  const isAuthenticated = hasValidAccess || hasValidRefresh;

  const authRoutes = ['/login', '/register'];
  const privateRoutes = ['/create']; // /explore is public
  
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
    const response = NextResponse.next();
    if (accessToken) response.cookies.delete('accessToken');
    if (refreshToken) response.cookies.delete('refreshToken');
    return response;
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/login', '/register', '/explore', '/create', '/'],
};
