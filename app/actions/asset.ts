'use server';

import { fetchApi } from '@/lib/api';

export async function getAssetAction(assetId: string) {
  try {
    const data = await fetchApi(`/assets/${assetId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch asset' };
  }
}

export async function getAssetDownloadUrlAction(assetId: string) {
  try {
    const data = await fetchApi(`/assets/download/${assetId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch download url' };
  }
}
