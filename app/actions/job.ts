'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';

export async function uploadAssetAction(formData: FormData) {
  try {
    const asset = await fetchApi('/assets/upload', {
      method: 'POST',
      body: formData,
    });
    return { success: true, asset };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to upload asset' };
  }
}

export async function createVideoJobAction(data: {
  prompt: string;
  negativePrompt?: string;
  presetId: string;
  inputAssetId?: string;
}) {
  try {
    const payload = {
      ...data,
      // includeBackgroundAudio: data.includeBackgroundAudio ?? true,
    };
    const job = await fetchApi('/jobs/video', {
      method: 'POST',
      body: JSON.stringify(payload),
    });

    // Refresh the page to show the new job
    revalidatePath('/create');

    return { success: true, job };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to create job' };
  }
}
