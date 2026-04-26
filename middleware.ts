import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const accessToken = request.cookies.get('accessToken')?.value;
  const refreshToken = request.cookies.get('refreshToken')?.value;
  
  const isAuthenticated = !!(accessToken || refreshToken);

  const authRoutes = ['/login', '/register'];
  const privateRoutes = ['/explore', '/create'];

  // Nếu đã đăng nhập, không cho phép vào trang login/register mà chuyển thẳng đến /explore
  if (isAuthenticated && authRoutes.includes(pathname)) {
    return NextResponse.redirect(new URL('/explore', request.url));
  }
  
  // Nếu chưa đăng nhập mà cố vào các trang yêu cầu đăng nhập, chuyển về trang /login
  const isPrivateRoute = privateRoutes.some(route => pathname.startsWith(route));
  if (!isAuthenticated && isPrivateRoute) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/login', '/register', '/explore', '/create', '/'],
};
