'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';

export async function publishVideoAction(assetId: string | null, assetVersionId: string | null, caption: string) {
  try {
    let resolvedVersionId = assetVersionId;

    // If we only have assetId (from Jobs), we need to fetch the asset to get its version ID
    if (!resolvedVersionId && assetId) {
      const asset = await fetchApi(`/assets/${assetId}`);
      if (!asset || !asset.versions || asset.versions.length === 0) {
        throw new Error("Could not find asset version for this job.");
      }
      resolvedVersionId = asset.versions[0].id;
    }

    if (!resolvedVersionId) {
      throw new Error("Missing asset version ID.");
    }

    // 1. Create the public Post
    await fetchApi('/posts', {
      method: 'POST',
      body: JSON.stringify({
        assetVersionId: resolvedVersionId,
        caption: caption,
        isPublic: true
      })
    });

    // 2. Add to user's public Gallery
    // Wait, POST /gallery might fail if it already exists in the gallery.
    // It's safer to try/catch the gallery POST separately so it doesn't break the whole action.
    try {
      await fetchApi('/gallery', {
        method: 'POST',
        body: JSON.stringify({
          assetVersionId: resolvedVersionId,
          isPublic: true
        })
      });
    } catch (e: any) {
      // Ignore gallery errors (e.g., if it already exists in the gallery)
    }

    revalidatePath('/explore');
    revalidatePath('/profile');
    
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to publish video' };
  }
}
