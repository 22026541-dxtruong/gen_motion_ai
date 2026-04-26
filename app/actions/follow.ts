'use server';

import { fetchApi } from '@/lib/api';

export async function followUserAction(followingId: string, sourcePostId?: string) {
  try {
    const data = await fetchApi('/follows', {
      method: 'POST',
      body: JSON.stringify({ followingId, sourcePostId }),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to follow user' };
  }
}

export async function unfollowUserAction(userId: string) {
  try {
    await fetchApi(`/follows/${userId}`, { method: 'DELETE' });
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to unfollow user' };
  }
}

export async function getFollowersAction(userId: string, cursor?: string, take: number = 20) {
  try {
    const params = new URLSearchParams({ take: take.toString() });
    if (cursor) params.set('cursor', cursor);
    const data = await fetchApi(`/users/${userId}/followers?${params.toString()}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch followers' };
  }
}

export async function getFollowingsAction(userId: string, cursor?: string, take: number = 20) {
  try {
    const params = new URLSearchParams({ take: take.toString() });
    if (cursor) params.set('cursor', cursor);
    const data = await fetchApi(`/users/${userId}/followings?${params.toString()}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch followings' };
  }
}
