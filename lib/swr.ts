'use client';

import useSWR, { SWRConfiguration } from 'swr';

// Global fetcher — calls our /api/proxy route which injects auth cookies
const fetcher = async (url: string) => {
  const res = await fetch(url);
  if (!res.ok) {
    const error: any = new Error('API error');
    try {
      const body = await res.json();
      error.info = body;
      error.status = res.status;
    } catch {}
    throw error;
  }
  return res.json();
};

// Default SWR config — stale-while-revalidate with long cache
export const swrConfig: SWRConfiguration = {
  fetcher,
  revalidateOnFocus: false,
  revalidateOnReconnect: false,
  dedupingInterval: 30000, // 30s dedup
};

// ─── Hooks ───────────────────────────────────────────────

export function useUser() {
  const { data, error, isLoading, mutate } = useSWR('/api/proxy/users/me', {
    revalidateOnFocus: false,
    dedupingInterval: 60000, // Cache user for 60s
    errorRetryCount: 1,
  });

  return {
    user: data,
    isLoading,
    isError: !!error,
    mutateUser: mutate,
  };
}

export function useJobs() {
  const { data, error, isLoading, mutate } = useSWR('/api/proxy/jobs', {
    dedupingInterval: 15000,
  });

  return {
    jobs: Array.isArray(data) ? data : [],
    isLoading,
    isError: !!error,
    mutateJobs: mutate,
  };
}

export function useExplorePosts(mode: string) {
  const key = `/api/proxy/posts?mode=${mode}`;
  const { data, error, isLoading, mutate } = useSWR(key, {
    dedupingInterval: 30000,
  });

  return {
    posts: Array.isArray(data) ? data : [],
    isLoading,
    isError: !!error,
    mutatePosts: mutate,
  };
}

export function useMyOrders() {
  const { data, error, isLoading, mutate } = useSWR('/api/proxy/billing/orders/me', {
    dedupingInterval: 15000,
  });

  return {
    orders: Array.isArray(data) ? data : [],
    isLoading,
    isError: !!error,
    mutateOrders: mutate,
  };
}

export function useBillingCatalog() {
  const { data, error, isLoading } = useSWR('/api/proxy/billing/catalog', {
    dedupingInterval: 300000, // Catalog rarely changes — cache 5min
    revalidateOnFocus: false,
  });

  return {
    catalog: data,
    isLoading,
    isError: !!error,
  };
}
