'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';

export async function getGalleryAction() {
  try {
    const data = await fetchApi('/gallery');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch gallery' };
  }
}

export async function createGalleryItemAction(assetVersionId: string, isPublic: boolean = true) {
  try {
    const data = await fetchApi('/gallery', {
      method: 'POST',
      body: JSON.stringify({ assetVersionId, isPublic }),
    });
    revalidatePath('/profile');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to add item to gallery' };
  }
}

export async function updateGalleryItemAction(galleryId: string, isPublic: boolean) {
  try {
    const data = await fetchApi(`/gallery/${galleryId}`, {
      method: 'PATCH',
      body: JSON.stringify({ isPublic }),
    });
    revalidatePath('/profile');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to update gallery item' };
  }
}

export async function deleteGalleryItemAction(galleryId: string) {
  try {
    await fetchApi(`/gallery/${galleryId}`, { method: 'DELETE' });
    revalidatePath('/profile');
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to delete gallery item' };
  }
}
