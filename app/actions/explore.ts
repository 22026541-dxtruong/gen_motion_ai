'use server';

import { fetchApi } from '@/lib/api';

const DEFAULT_EXPLORE_LIMIT = 20;

export async function fetchExploreAction(
  mode: string,
  params?: {
    topic?: string;
    trending?: string | boolean;
    sort?: string;
    limit?: number;
    cursor?: string;
  }
) {
  try {
    const searchParams = new URLSearchParams();
    searchParams.set('limit', (params?.limit || DEFAULT_EXPLORE_LIMIT).toString());
    if (mode && mode !== 'for_you') searchParams.set('mode', mode);
    if (params?.topic) searchParams.set('topic', params.topic);
    if (params?.trending !== undefined) searchParams.set('trending', String(params.trending));
    if (params?.sort) searchParams.set('sort', params.sort);
    if (params?.cursor) searchParams.set('cursor', params.cursor);

    const data = await fetchApi(`/explore?${searchParams.toString()}`, {
      cache: 'no-store',
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch' };
  }
}

/**
 * GET /explore/search
 * Search for ExploreItems by topic
 */
export async function fetchExploreSearchAction(
  topic: string,
  params?: {
    sort?: string;
    trending?: string | boolean;
    limit?: number;
    cursor?: string;
  }
) {
  try {
    const searchParams = new URLSearchParams();
    searchParams.set('topic', topic);
    searchParams.set('limit', (params?.limit || DEFAULT_EXPLORE_LIMIT).toString());
    if (params?.sort) searchParams.set('sort', params.sort);
    if (params?.trending !== undefined) searchParams.set('trending', String(params.trending));
    if (params?.cursor) searchParams.set('cursor', params.cursor);

    const data = await fetchApi(`/explore/search?${searchParams.toString()}`, {
      cache: 'no-store',
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to search' };
  }
}

/**
 * GET /explore/for-you
 */
export async function fetchExploreForYouAction(
  params?: {
    topic?: string;
    limit?: number;
    cursor?: string;
  }
) {
  try {
    const searchParams = new URLSearchParams();
    searchParams.set('limit', (params?.limit || DEFAULT_EXPLORE_LIMIT).toString());
    if (params?.topic) searchParams.set('topic', params.topic);
    if (params?.cursor) searchParams.set('cursor', params.cursor);

    const data = await fetchApi(`/explore/for-you?${searchParams.toString()}`, {
      cache: 'no-store',
    });
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to fetch for-you' };
  }
}

/**
 * Track a single explore event (IMPRESSION, OPEN_POST, LIKE, etc.)
 * POST /explore/events
 */
export async function trackExploreEventAction(
  postId: string,
  eventType: 'IMPRESSION' | 'OPEN_POST' | 'WATCH_3S' | 'WATCH_50' | 'LIKE' | 'COMMENT' | 'FOLLOW_CREATOR' | 'HIDE',
  metadata?: Record<string, unknown>
) {
  try {
    const data = await fetchApi('/explore/events', {
      method: 'POST',
      body: JSON.stringify({ postId, eventType, metadata: metadata || { surface: 'explore_grid' } }),
    });
    return { success: true, data };
  } catch {
    // Non-critical, silently fail
    return { success: false };
  }
}

/**
 * Batch track multiple explore events
 * POST /explore/events/batch
 */
export async function trackExploreEventsBatchAction(
  events: Array<{
    postId: string;
    eventType: string;
    metadata?: Record<string, unknown>;
  }>
) {
  try {
    const data = await fetchApi('/explore/events/batch', {
      method: 'POST',
      body: JSON.stringify({ events }),
    });
    return { success: true, data };
  } catch {
    return { success: false };
  }
}
