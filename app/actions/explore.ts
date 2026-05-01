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

/**
 * GET /explore/search
 * Search for ExploreItems by topic
 */
export async function fetchExploreSearchAction(topic: string, cursor?: string) {
  try {
    const data = await fetchApi(`/explore/search?topic=${encodeURIComponent(topic)}&limit=10${cursor ? `&cursor=${cursor}` : ''}`);
    return { success: true, data };
  } catch (error: any) {
    return { success: false, error: error.message || 'Failed to search' };
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
