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
