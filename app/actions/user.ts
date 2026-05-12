'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';

export async function updateUserProfileAction(data: { username?: string; bio?: string; avatarUrl?: string }) {
  try {
    const updatedUser = await fetchApi('/users/me', {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
    
    revalidatePath('/', 'layout');
    
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

export async function getUserFollowersAction(userId: string, cursor?: string) {
  try {
    const data = await fetchApi(`/users/${userId}/followers${cursor ? `?cursor=${cursor}` : ''}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch followers' };
  }
}

export async function getUserFollowingsAction(userId: string, cursor?: string) {
  try {
    const data = await fetchApi(`/users/${userId}/followings${cursor ? `?cursor=${cursor}` : ''}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch followings' };
  }
}

export async function checkFollowStatusAction(targetUserId: string) {
  if (!targetUserId) return { isFollowing: false };
  try {
    const [user, followersData] = await Promise.all([
      fetchApi('/users/me'),
      fetchApi(`/users/${targetUserId}/followers?take=50`),
    ]);
    if (!user?.id) return { isFollowing: false };
    const followers = followersData?.data || [];
    const isFollowing = followers.some((f: any) => f.follower?.id === user.id);
    return { isFollowing };
  } catch {
    return { isFollowing: false };
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
    revalidatePath('/', 'layout');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to topup credits' };
  }
}

export async function followUserAction(userId: string) {
  try {
    const data = await fetchApi(`/follows`, {
      method: 'POST',
      body: JSON.stringify({ followingId: userId })
    });
    revalidatePath(`/user/${userId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to follow user' };
  }
}

export async function unfollowUserAction(userId: string) {
  try {
    const data = await fetchApi(`/follows/${userId}`, {
      method: 'DELETE',
    });
    revalidatePath(`/user/${userId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to unfollow user' };
  }
}
