'use server';

import { fetchApi } from '@/lib/api';
import { revalidatePath } from 'next/cache';
import { buildApiUrl } from '@/lib/runtime-config';

/**
 * GET /posts/:id — Auth: Bearer JWT (token optional for public posts)
 *
 * Response includes videoUrl, thumbnailUrl, assetVersion etc.
 * However, these fields are often NULL (backend doesn't generate signed URLs inline).
 *
 * When videoUrl is null, we use metadata.sourceJobId to fetch the job,
 * which includes output.downloadUrl (a signed S3 URL for the video).
 */
export async function getPostAction(postId: string) {
  try {
    const data = await fetchApi(`/posts/${postId}`);

    // The backend now natively returns videoUrl and thumbnailUrl.
    // If not directly present, we can optionally map them from assetVersion as a fallback,
    // though the backend should handle this now.
    if (data && !data.videoUrl && data.assetVersion?.fileUrl) {
      data.videoUrl = data.assetVersion.fileUrl;
    }

    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch post' };
  }
}

/**
 * POST /posts/:postId/post-likes — Like a post
 * Body: { postId }
 * Response: { id, userId, postId, createdAt }
 */
export async function likePostAction(postId: string) {
  if (!postId) return { success: false, error: 'Missing postId' };
  try {
    const data = await fetchApi(`/posts/${postId}/post-likes`, {
      method: 'POST',
      body: JSON.stringify({ postId }),
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to like post' };
  }
}

/**
 * DELETE /posts/:postId/post-likes — Unlike a post
 * Auth: Bearer JWT
 * Response: { id, userId, postId, createdAt }
 */
export async function unlikePostAction(postId: string, likedUserId?: string) {
  if (!postId) return { success: false, error: 'Missing postId' };
  try {
    const params = new URLSearchParams();
    if (likedUserId?.trim()) {
      params.set('userId', likedUserId.trim());
    }
    const query = params.toString();
    const data = await fetchApi(`/posts/${postId}/post-likes${query ? `?${query}` : ''}`, {
      method: 'DELETE',
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to unlike post' };
  }
}

/**
 * POST /posts/:postId/comments — Add a comment

 * Auth: Bearer JWT
 * Body: { content, postId? }
 * Response: { id, userId, postId, content, createdAt }
 */
export async function addCommentAction(postId: string, content: string) {
  if (!postId) return { success: false, error: 'Missing postId' };
  try {
    const data = await fetchApi(`/posts/${postId}/comments`, {
      method: 'POST',
      body: JSON.stringify({ content, postId }),
    });
    revalidatePath(`/post/${postId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to post comment' };
  }
}

/**
 * GET /posts/:postId/comments — Fetch comments (paginated)
 * Auth: Bearer JWT
 * Query: cursor?, take? (1..50, default 20)
 * Response: { data: [{ id, content, createdAt, user: { id, username } }], nextCursor }
 */
export async function fetchPostCommentsAction(postId: string, cursor?: string) {
  try {
    const params = new URLSearchParams();
    if (cursor) params.set('cursor', cursor);
    params.set('take', '20');
    const data = await fetchApi(`/posts/${postId}/comments?${params.toString()}`);
    return { success: true, data };
  } catch {
    // Silently fail — user may not be logged in
    return { success: true, data: { data: [], nextCursor: null } };
  }
}

/**
 * POST /posts — Publish a video as a public post
 *
 * Resolution chain for assetVersionId:
 *   1. Direct assetVersionId (if provided)
 *   2. GET /assets/:assetId → versions[0].id
 *   3. GET /jobs/:jobId → output.assetId → GET /assets/:assetId → versions[0].id
 */
export async function publishVideoAction(
  assetId: string | null,
  assetVersionId: string | null,
  caption: string,
  jobId: string | null = null
) {
  try {
    let resolvedVersionId = assetVersionId;
    let resolvedAssetId = assetId;

    // If no assetId and no versionId, try to get them from the job
    if (!resolvedVersionId && !resolvedAssetId && jobId) {
      const job = await fetchApi(`/jobs/${jobId}`);
      if (job?.output?.assetId) {
        resolvedAssetId = job.output.assetId;
      }
    }

    // Resolve assetVersionId from assetId
    if (!resolvedVersionId && resolvedAssetId) {
      const asset = await fetchApi(`/assets/${resolvedAssetId}`);
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

/**
 * GET /posts — Auth: Public
 */
export async function getPostsAction() {
  try {
    const res = await fetch(buildApiUrl('/posts'), {
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
    return { success: false, error: error.message || 'Failed to fetch posts' };
  }
}

/**
 * PATCH /posts/:id — Auth: Bearer JWT
 */
export async function updatePostAction(postId: string, payload: { assetVersionId?: string; caption?: string; isPublic?: boolean }) {
  try {
    const data = await fetchApi(`/posts/${postId}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    });
    revalidatePath(`/post/${postId}`);
    revalidatePath('/explore');
    revalidatePath('/profile');
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to update post' };
  }
}

/**
 * PATCH /comments/:id — Auth: Bearer JWT
 */
export async function updateCommentAction(commentId: string, payload: { postId?: string; content?: string }) {
  try {
    const data = await fetchApi(`/comments/${commentId}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    });
    if (payload.postId) revalidatePath(`/post/${payload.postId}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to update comment' };
  }
}

/**
 * DELETE /comments/:id — Auth: Bearer JWT
 */
export async function deleteCommentAction(commentId: string, postId?: string) {
  try {
    await fetchApi(`/comments/${commentId}`, { method: 'DELETE' });
    if (postId) revalidatePath(`/post/${postId}`);
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to delete comment' };
  }
}

/**
 * GET /posts/:postId/post-likes — Auth: Bearer JWT
 * Query: cursor?, take? (1..50, default 20)
 * Response: { data: [{ id, createdAt, user: { id, username } }], nextCursor }
 */
export async function getPostLikesAction(postId: string, cursor?: string) {
  try {
    const params = new URLSearchParams({ take: '20' });
    if (cursor) params.set('cursor', cursor);
    const data = await fetchApi(`/posts/${postId}/post-likes?${params.toString()}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: true, data: { data: [], nextCursor: null } };
  }
}

/**
 * Check if the current user has liked a post.
 * Fetches user profile + post likes and compares.
 */
export async function getPostLikeStatusAction(postId: string) {
  if (!postId) return { isLiked: false };
  try {
    const [user, likesData] = await Promise.all([
      fetchApi('/users/me'),
      fetchApi(`/posts/${postId}/post-likes?take=50`),
    ]);
    if (!user?.id) return { isLiked: false };
    const likes = likesData?.data || [];
    const isLiked = likes.some((like: any) => like.user?.id === user.id);
    return { isLiked };
  } catch {
    return { isLiked: false };
  }
}
