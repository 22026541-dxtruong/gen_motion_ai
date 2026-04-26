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

export async function getJobsAction() {
  try {
    const data = await fetchApi('/jobs');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch jobs' };
  }
}

export async function getJobByIdAction(jobId: string) {
  try {
    const data = await fetchApi(`/jobs/${jobId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch job' };
  }
}

export async function getJobResultAction(jobId: string) {
  try {
    const data = await fetchApi(`/jobs/${jobId}/result`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch job result' };
  }
}

export async function cancelJobAction(jobId: string) {
  try {
    const data = await fetchApi(`/jobs/${jobId}/cancel`, { method: 'POST' });
    revalidatePath('/create');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to cancel job' };
  }
}
