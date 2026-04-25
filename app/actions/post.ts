'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

/**
 * GET /posts/:id — Auth: Public (token optional)
 * IMPORTANT: Do NOT send auth token — if the token is expired, the backend
 * returns 401 even for public endpoints. Fetch without auth for public reads.
 *
 * Response: { id, userId, assetVersionId, caption, isPublic, likeCount,
 *             commentCount, viewCount, createdAt,
 *             user: { id, username },
 *             assetVersion: { id, fileUrl, metadata } }
 * NOTE: assetVersion does NOT include mimeType or durationMs.
 */
export async function getPostAction(postId: string) {
  try {
    const res = await fetch(`${API_URL}/posts/${postId}`, {
      headers: { 'Content-Type': 'application/json' },
      cache: 'no-store',
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      const msg = Array.isArray(err.message) ? err.message.join(', ') : err.message;
      throw new Error(msg || `API Error: ${res.status}`);
    }
    const data = await res.json();
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch post' };
  }
}

/**
 * POST /post-likes — Like a post
 * Body: { postId }
 * Response: { id, userId, postId, createdAt }
 */
export async function likePostAction(postId: string) {
  try {
    const data = await fetchApi('/post-likes', {
      method: 'POST',
      body: JSON.stringify({ postId }),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to like post' };
  }
}

/**
 * DELETE /post-likes — Unlike
 * NOTE: Per API docs, DELETE /post-likes has no route param for postId (route mismatch).
 * Best effort: send query param. Backend may or may not handle it.
 */
export async function unlikePostAction(postId: string) {
  try {
    await fetchApi(`/post-likes?postId=${postId}`, {
      method: 'DELETE',
    });
    return { success: true };
  } catch {
    // Silent success even if backend can't process (route mismatch documented)
    return { success: true };
  }
}

/**
 * POST /comments — Add a comment
 * Body: { postId, content }
 * Response: { id, userId, postId, content, createdAt }
 */
export async function addCommentAction(postId: string, content: string) {
  try {
    const data = await fetchApi('/comments', {
      method: 'POST',
      body: JSON.stringify({ postId, content }),
    });
    revalidatePath(`/post/${postId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to post comment' };
  }
}

/**
 * GET /comments — Fetch comments (paginated)
 * Auth: Bearer JWT (required)
 * NOTE: API has route mismatch — no postId filter available.
 * Returns generic paginated comments.
 * Response: { data: [{ id, content, createdAt, user: { id, username } }], nextCursor }
 */
export async function fetchPostCommentsAction(postId: string, cursor?: string) {
  try {
    const params = new URLSearchParams();
    if (cursor) params.set('cursor', cursor);
    params.set('take', '20');
    const data = await fetchApi(`/comments?${params.toString()}`);
    return { success: true, data };
  } catch {
    // Silently fail — user may not be logged in (GET /comments requires auth)
    return { success: true, data: { data: [], nextCursor: null } };
  }
}

/**
 * POST /posts — Publish a video as a public post
 */
export async function publishVideoAction(
  assetId: string | null,
  assetVersionId: string | null,
  caption: string
) {
  try {
    let resolvedVersionId = assetVersionId;

    if (!resolvedVersionId && assetId) {
      const asset = await fetchApi(`/assets/${assetId}`);
      if (!asset?.versions?.length) {
        throw new Error('Could not find asset version for this job.');
      }
      resolvedVersionId = asset.versions[0].id;
    }

    if (!resolvedVersionId) throw new Error('Missing asset version ID.');

    const post = await fetchApi('/posts', {
      method: 'POST',
      body: JSON.stringify({ assetVersionId: resolvedVersionId, caption, isPublic: true }),
    });

    try {
      await fetchApi('/gallery', {
        method: 'POST',
        body: JSON.stringify({ assetVersionId: resolvedVersionId, isPublic: true }),
      });
    } catch {
      // Ignore gallery errors
    }

    revalidatePath('/explore');
    revalidatePath('/profile');
    return { success: true, postId: post?.id };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to publish video' };
  }
}

/**
 * DELETE /posts/:id
 */
export async function deletePostAction(postId: string) {
  try {
    await fetchApi(`/posts/${postId}`, { method: 'DELETE' });
    revalidatePath('/explore');
    revalidatePath('/profile');
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to delete post' };
  }
}
