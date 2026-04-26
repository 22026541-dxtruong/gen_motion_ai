'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { fetchApi } from '@/lib/api';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export async function loginAction(formData: FormData) {
  const email = formData.get('email');
  const password = formData.get('password');

  const res = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  if (!res.ok) {
    const errorData = await res.json().catch(() => ({}));
    return { error: errorData.message || 'Login failed' };
  }

  const data = await res.json();
  
  const cookieStore = await cookies();
  // Set tokens in HTTP-only cookies
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

  // Also save account-specific tokens for Switch Account feature
  if (email && typeof email === 'string') {
    cookieStore.set(`access_${email}`, data.accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 7,
    });
    if (data.refreshToken) {
      cookieStore.set(`refresh_${email}`, data.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 30,
      });
    }
  }

  return { success: true };
}

export async function registerAction(formData: FormData) {
  const email = formData.get('email');
  const password = formData.get('password');
  // Optional: username if your backend requires it in register, though the spec says email and password only.
  
  const res = await fetch(`${API_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  if (!res.ok) {
    const errorData = await res.json().catch(() => ({}));
    return { error: errorData.message || 'Registration failed' };
  }

  const data = await res.json();
  
  const cookieStore = await cookies();
  cookieStore.set('accessToken', data.accessToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  });
  
  if (data.refreshToken) {
    cookieStore.set('refreshToken', data.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 30,
    });
  }

  // Also save account-specific tokens for Switch Account feature
  if (email && typeof email === 'string') {
    cookieStore.set(`access_${email}`, data.accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 7,
    });
    if (data.refreshToken) {
      cookieStore.set(`refresh_${email}`, data.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 30,
      });
    }
  }

  return { success: true };
}

export async function logoutAction() {
  const cookieStore = await cookies();
  const refreshToken = cookieStore.get('refreshToken')?.value;

  if (refreshToken) {
    const token = cookieStore.get('accessToken')?.value;
    await fetch(`${API_URL}/auth/logout`, {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {})
      },
      body: JSON.stringify({ refreshToken }),
    }).catch(() => {}); // ignore errors on logout
  }

  cookieStore.delete('accessToken');
  cookieStore.delete('refreshToken');
  
  redirect('/login');
}

export async function changePasswordAction(formData: FormData) {
  const oldPassword = formData.get('oldPassword') as string;
  const newPassword = formData.get('newPassword') as string;

  try {
    await fetchApi('/auth/change-password', {
      method: 'PATCH',
      body: JSON.stringify({ oldPassword, newPassword }),
    });
    return { success: true };
  } catch (error: any) {
    return { error: error.message || 'Change password failed' };
  }
}

export async function switchAccountAction(email: string) {
  const cookieStore = await cookies();
  const accountAccess = cookieStore.get(`access_${email}`)?.value;
  const accountRefresh = cookieStore.get(`refresh_${email}`)?.value;

  if (accountAccess) {
    cookieStore.set('accessToken', accountAccess, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 7,
    });
    
    if (accountRefresh) {
      cookieStore.set('refreshToken', accountRefresh, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 30,
      });
    }
    
    return { success: true };
  }
  
  // No token found for this account, require login
  return { requireLogin: true, email };
}

export async function removeSavedAccountAction(email: string) {
  const cookieStore = await cookies();
  cookieStore.delete(`access_${email}`);
  cookieStore.delete(`refresh_${email}`);
  return { success: true };
}
