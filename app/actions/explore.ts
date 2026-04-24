'use server';

import { fetchApi } from '@/lib/api';

export async function fetchExploreAction(mode: string, cursor?: string) {
  try {
    const data = await fetchApi(`/explore?limit=10&mode=${mode}${cursor ? `&cursor=${cursor}` : ''}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch' };
  }
}
