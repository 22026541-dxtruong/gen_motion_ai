'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { fetchApi } from '@/lib/api';
import { buildApiUrl } from '@/lib/runtime-config';

function getErrorMessage(error: unknown, fallback: string): string {
  return error instanceof Error ? error.message : fallback;
}

export async function loginAction(formData: FormData) {
  const email = formData.get('email');
  const password = formData.get('password');

  const res = await fetch(buildApiUrl('/auth/login'), {
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
  
  const res = await fetch(buildApiUrl('/auth/register'), {
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
    await fetch(buildApiUrl('/auth/logout'), {
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
  } catch (error: unknown) {
    return { error: getErrorMessage(error, 'Change password failed') };
  }
}

export async function switchAccountAction(email: string) {
  const cookieStore = await cookies();
  const accountAccess = cookieStore.get(`access_${email}`)?.value;
  const accountRefresh = cookieStore.get(`refresh_${email}`)?.value;

  if (accountAccess) {
    // Validate the token against the API to ensure it hasn't expired or been revoked
    const res = await fetch(buildApiUrl('/users/me'), {
      headers: {
        'Authorization': `Bearer ${accountAccess}`,
        'Content-Type': 'application/json'
      }
    });

    if (res.ok) {
      // Token is valid, perform the switch
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
    } else {
      // Token is invalid/expired, delete the dead cookies
      cookieStore.delete(`access_${email}`);
      cookieStore.delete(`refresh_${email}`);
    }
  }
  
  // No token found (or it was invalid), require login
  return { requireLogin: true, email };
}

export async function removeSavedAccountAction(email: string) {
  const cookieStore = await cookies();
  cookieStore.delete(`access_${email}`);
  cookieStore.delete(`refresh_${email}`);
  return { success: true };
}

export async function logoutAllAction() {
  try {
    await fetchApi('/auth/logout-all', { method: 'POST' });
    const cookieStore = await cookies();
    cookieStore.delete('accessToken');
    cookieStore.delete('refreshToken');
    return { success: true };
  } catch (error: unknown) {
    return { success: false, error: getErrorMessage(error, 'Logout all failed') };
  }
}

export async function forgotPasswordAction(email: string) {
  try {
    const res = await fetch(buildApiUrl('/auth/forgot-password'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || 'Failed to request password reset');
    }
    return { success: true };
  } catch (error: unknown) {
    return { success: false, error: getErrorMessage(error, 'Failed to request password reset') };
  }
}

export async function resetPasswordAction(token: string, newPassword: string) {
  try {
    const res = await fetch(buildApiUrl('/auth/reset-password'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token, newPassword }),
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || 'Failed to reset password');
    }
    return { success: true };
  } catch (error: unknown) {
    return { success: false, error: getErrorMessage(error, 'Failed to reset password') };
  }
}

export async function googleExchangeCodeAction(code: string) {
  try {
    const res = await fetch(buildApiUrl('/auth/google/exchange-code'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || 'Google Login failed');
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

    if (data.email && typeof data.email === 'string') {
      cookieStore.set(`access_${data.email}`, data.accessToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 7,
      });

      if (data.refreshToken) {
        cookieStore.set(`refresh_${data.email}`, data.refreshToken, {
          httpOnly: true,
          secure: process.env.NODE_ENV === 'production',
          sameSite: 'lax',
          path: '/',
          maxAge: 60 * 60 * 24 * 30,
        });
      }
    }

    return { success: true };
  } catch (error: unknown) {
    return { success: false, error: getErrorMessage(error, 'Google Login failed') };
  }
}
