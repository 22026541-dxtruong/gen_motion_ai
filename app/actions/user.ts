'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';

export async function updateUserProfileAction(data: { username?: string; bio?: string }) {
  try {
    const updatedUser = await fetchApi('/users/me', {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
    
    revalidatePath('/profile');
    
    return { success: true, user: updatedUser };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to update profile' };
  }
}

export async function getUserProfileAction(cursor?: string, take: number = 20) {
  try {
    const params = new URLSearchParams();
    if (cursor) params.set('cursor', cursor);
    if (take) params.set('take', take.toString());
    const data = await fetchApi(`/users/me?${params.toString()}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch user profile' };
  }
}

export async function getUserByIdAction(userId: string) {
  try {
    const data = await fetchApi(`/users/${userId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch user' };
  }
}

export async function deleteUserAction() {
  try {
    await fetchApi('/users/me', { method: 'DELETE' });
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to delete user' };
  }
}

export async function topupCreditsAction(amount: number, note?: string) {
  try {
    const data = await fetchApi('/users/me/credits/topup', {
      method: 'POST',
      body: JSON.stringify({ amount, note }),
    });
    revalidatePath('/profile');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to topup credits' };
  }
}
