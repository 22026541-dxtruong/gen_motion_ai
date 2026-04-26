'use server';

import { fetchApi } from '@/lib/api';

export async function generateModalVideoAction(payload: any) {
  try {
    const data = await fetchApi('/modal/generate-video', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to generate modal video' };
  }
}
