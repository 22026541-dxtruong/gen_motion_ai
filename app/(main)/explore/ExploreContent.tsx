"use client";

import React, { useState, useEffect, useCallback, useRef } from "react";
import Link from "next/link";
import {
  Sparkles,
  Play,
  Compass,
  Flame,
  Star,
  Clock,
} from "lucide-react";
import ExploreFeed from "./ExploreFeed";
import ExplorePublishButton from "./ExplorePublishButton";
import ExploreSearch from "./ExploreSearch";
import {
  fetchExploreAction,
  fetchExploreSearchAction,
  fetchExploreForYouAction,
} from "@/app/actions/explore";

type TabCache = {
  items: any[];
  nextCursor: string | null;
  signals: any;
  updatedAt: number;
};

type ExploreContentProps = {
  isAuthenticated: boolean;
  userJobs: any[];
  initialMode: string;
  initialTopic: string;
  initialSort: string;
  initialTrending: boolean;
};

const EXPLORE_PAGE_SIZE = 20;
const TAB_CACHE_FRESH_MS = 8_000;

export default function ExploreContent({
  isAuthenticated,
  userJobs,
  initialMode,
  initialTopic,
  initialSort,
  initialTrending,
}: ExploreContentProps) {
  const resolvedMode =
    initialMode === "for_you" && !isAuthenticated ? "trending" : initialMode;
  const [activeMode, setActiveMode] = useState(
    resolvedMode
  );
  const topic = initialTopic;
  const sort = initialSort;
  const trending = initialTrending;

  // ── Per-tab cache ─────────────────────────────────────────────────────────
  const cacheRef = useRef<Record<string, TabCache>>({});

  const [items, setItems] = useState<any[]>([]);
  const [nextCursor, setNextCursor] = useState<string | null>(null);
  const [signals, setSignals] = useState<any>(null);
  const [featuredItems, setFeaturedItems] = useState<any[]>([]);
  const featuredLoaded = useRef(false);
  const [isPageLoading, setIsPageLoading] = useState(true);

  const showFeatured = !topic && activeMode !== "for_you";

  useEffect(() => {
    setActiveMode(resolvedMode);
  }, [resolvedMode]);

  const tabs = [
    ...(isAuthenticated
      ? [{ id: "for_you", label: "For You", icon: Sparkles }]
      : []),
    { id: "trending", label: "Trending", icon: Flame },
    { id: "top", label: "Top", icon: Star },
    { id: "new", label: "New", icon: Clock },
  ];

  // Apply cached data to state instantly
  const applyCachedData = useCallback((cached: TabCache) => {
    setItems(cached.items);
    setNextCursor(cached.nextCursor);
    setSignals(cached.signals);
  }, []);

  const fetchData = useCallback(
    async (mode: string) => {
      const cacheKey = `${mode}|topic:${topic}|sort:${sort}|trending:${trending}|auth:${isAuthenticated}`;

      // ── Check cache first → instant display ──
      const cached = cacheRef.current[cacheKey];
      const hasCached = Boolean(cached);
      let shouldBackgroundRefresh = false;
      if (cached) {
        applyCachedData(cached);
        setIsPageLoading(false);
        shouldBackgroundRefresh =
          Date.now() - cached.updatedAt >= TAB_CACHE_FRESH_MS;
        if (!shouldBackgroundRefresh) {
          return;
        }
      }

      if (!hasCached) {
        setIsPageLoading(true);
      }
      try {
        let exploreRes: any;

        if (topic) {
          exploreRes = await fetchExploreSearchAction(topic, {
            sort,
            trending,
            limit: EXPLORE_PAGE_SIZE,
          });
        } else if (mode === "for_you") {
          exploreRes = await fetchExploreForYouAction({ limit: EXPLORE_PAGE_SIZE });
        } else {
          exploreRes = await fetchExploreAction(mode, {
            sort,
            trending,
            limit: EXPLORE_PAGE_SIZE,
          });
        }

        // Fetch featured items only once
        if (!featuredLoaded.current && !topic) {
          try {
            let featuredRes: any;
            if (isAuthenticated) {
              featuredRes = await fetchExploreForYouAction({ limit: 5 });
            } else {
              featuredRes = await fetchExploreAction("trending", { limit: 5 });
            }
            if (featuredRes?.success && featuredRes.data) {
              setFeaturedItems(featuredRes.data.data || []);
            }
          } catch {
            // Non-critical
          }
          featuredLoaded.current = true;
        }

        if (exploreRes?.success && exploreRes.data) {
          const newItems = exploreRes.data.data || [];
          const newCursor = exploreRes.data.nextCursor || null;
          const newSignals = exploreRes.data.signals || null;

          // Save to cache
          cacheRef.current[cacheKey] = {
            items: newItems,
            nextCursor: newCursor,
            signals: newSignals,
            updatedAt: Date.now(),
          };

          setItems(newItems);
          setNextCursor(newCursor);
          setSignals(newSignals);
        } else if (!hasCached) {
          setItems([]);
          setNextCursor(null);
          setSignals(null);
        }
      } catch (error) {
        console.error("Failed to fetch explore data:", error);
        if (!hasCached) {
          setItems([]);
          setNextCursor(null);
        }
      }
      if (!hasCached) {
        setIsPageLoading(false);
      }
    },
    [topic, sort, trending, isAuthenticated, applyCachedData]
  );

  // Load data on mount and when mode changes
  useEffect(() => {
    fetchData(activeMode);
  }, [activeMode, fetchData]);

  const handleTabChange = (tabId: string) => {
    if (tabId === activeMode) return;
    setActiveMode(tabId);
    // Update URL without triggering a full page reload
    const url = new URL(window.location.href);
    url.searchParams.set("mode", tabId);
    window.history.replaceState({}, "", url.toString());
  };

  return (
    <div className="max-w-6xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between mb-8 gap-4">
        <div className="max-w-xl">
          <h2 className="text-3xl font-bold text-slate-900 dark:text-slate-100 mb-2">
            {topic ? `Search: ${topic}` : "Explore"}
          </h2>
          <p className="text-slate-500 dark:text-slate-400 text-sm">
            {topic
              ? "Showing results for your topic."
              : "Discover the latest cinematic masterpieces generated by the Neura Gen community."}
          </p>
        </div>

        <div className="flex flex-col sm:flex-row items-center gap-4">
          <ExploreSearch key={`${topic}|${sort}|${trending}`} />
        </div>
      </div>

      {/* Mode Tabs */}
      {!topic && (
        <div className="flex overflow-x-auto hide-scrollbar mb-8 pb-2">
          <div className="flex bg-white/50 dark:bg-slate-900/50 backdrop-blur-md p-1.5 rounded-2xl border border-slate-200/60 dark:border-slate-800 shadow-sm">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeMode === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => handleTabChange(tab.id)}
                  className={`flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-xl transition-all duration-300 ${isActive
                      ? "bg-white dark:bg-slate-800 text-indigo-600 dark:text-indigo-400 shadow-[0_2px_10px_rgba(0,0,0,0.06)]"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:hover:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800"
                    }`}
                >
                  <Icon
                    size={16}
                    className={
                      isActive ? "text-indigo-600 dark:text-indigo-400" : "text-slate-400 dark:text-slate-500"
                    }
                  />
                  {tab.label}
                </button>
              );
            })}
          </div>
        </div>
      )}

      {/* Loading Skeleton — only shown on first load of a tab */}
      {isPageLoading && (
        <div className="space-y-8 animate-pulse">
          {showFeatured && !featuredLoaded.current && (
            <div className="mb-12">
              <div className="h-6 w-48 bg-slate-200 dark:bg-slate-800 rounded mb-4" />
              <div className="h-[350px] bg-slate-100 dark:bg-slate-800 rounded-[2rem]" />
            </div>
          )}
          <div>
            <div className="h-6 w-40 bg-slate-200 dark:bg-slate-800 rounded mb-6" />
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className="bg-slate-100 dark:bg-slate-800 rounded-3xl h-72" />
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Content */}
      {!isPageLoading && (
        <>
          {/* Featured Carousel Section */}
          {showFeatured && (
            <div className="mb-12">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <Sparkles className="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
                  <h3 className="text-xl font-bold text-slate-900 dark:text-slate-100">
                    Featured Spotlights
                  </h3>
                </div>
              </div>

              {featuredItems.length > 0 ? (
                <div className="flex overflow-x-auto snap-x snap-mandatory gap-6 pb-4 hide-scrollbar">
                  {featuredItems.map((item: any) => {
                    const videoUrl =
                      item.videoUrl ||
                      item.post?.videoUrl ||
                      item.assetVersion?.fileUrl;
                    const thumbnailUrl =
                      item.thumbnailUrl || item.post?.thumbnailUrl;
                    const isVideo =
                      !!videoUrl &&
                      (item.assetVersion?.mimeType?.startsWith("video/") ||
                        /\.(mp4|webm|mov)(\?|$)/i.test(videoUrl));
                    const displayUrl =
                      videoUrl ||
                      "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?auto=format&fit=crop&q=80&w=1200";

                    return (
                      <div
                        key={item.id}
                        className="min-w-[85vw] md:min-w-[60vw] lg:min-w-[800px] h-[350px] md:h-[400px] snap-center relative rounded-[2rem] overflow-hidden group cursor-pointer shadow-lg shrink-0 border border-slate-100"
                      >
                        <Link
                          href={`/post/${item.postId || item.id}`}
                          className="absolute inset-0 z-10"
                        />

                        {isVideo ? (
                          <video
                            src={displayUrl}
                            poster={
                              thumbnailUrl ||
                              "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?auto=format&fit=crop&q=80&w=1200"
                            }
                            className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                            autoPlay
                            loop
                            muted
                            playsInline
                          />
                        ) : (
                          <img
                            src={thumbnailUrl || displayUrl}
                            alt={item.title || "Featured Video"}
                            className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                          />
                        )}

                        <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/30 to-transparent p-6 md:p-8 flex flex-col justify-end pointer-events-none">
                          <div className="mb-auto mt-2 pointer-events-auto relative z-20 w-fit">
                            <span className="bg-white/20 backdrop-blur-md text-white text-xs font-bold px-4 py-1.5 rounded-full tracking-wider border border-white/30 shadow-sm uppercase">
                              {isAuthenticated ? "Recommended" : "Trending"}
                            </span>
                          </div>
                          <div className="flex justify-between items-end pointer-events-auto relative z-20">
                            <div>
                              <h4 className="text-2xl md:text-3xl lg:text-4xl font-extrabold text-white mb-3 md:mb-4 leading-tight">
                                {item.title || "Untitled Video"}
                              </h4>
                              <Link
                                href={`/user/${item.post?.user?.id ||
                                  item.post?.user?.username ||
                                  "unknown"
                                  }`}
                                className="flex items-center gap-3 text-white/90 hover:text-white transition-colors w-fit bg-black/20 backdrop-blur-sm pr-4 py-1.5 pl-1.5 rounded-full border border-white/10"
                              >
                                <img
                                  src={
                                    item.post?.user?.avatarUrl ||
                                    `https://ui-avatars.com/api/?name=${encodeURIComponent(
                                      item.post?.user?.username || "Creator"
                                    )}&background=e0e7ff&color=4f46e5`
                                  }
                                  alt="Creator"
                                  className="w-6 h-6 md:w-8 md:h-8 rounded-full border-2 border-white/80 object-cover bg-slate-100"
                                />
                                <p className="font-semibold text-xs md:text-sm tracking-wide">
                                  {item.post?.user?.username ||
                                    "Unknown Creator"}
                                </p>
                              </Link>
                            </div>
                            <button className="bg-white/20 backdrop-blur-md hover:bg-white/30 text-white rounded-full p-3 md:p-4 transition-all duration-300 hover:scale-110 shadow-lg border border-white/20">
                              <Play className="h-5 w-5 md:h-6 md:w-6 fill-current" />
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div className="w-full h-40 flex items-center justify-center border border-slate-100 dark:border-slate-800 rounded-[2rem] bg-slate-50 dark:bg-slate-800/50 text-slate-400 dark:text-slate-500 font-medium">
                  Check back later for personalized recommendations.
                </div>
              )}
            </div>
          )}

          {/* Recent Discoveries Section */}
          <div>
            <div className="flex items-center gap-2 mb-6">
              <Compass className="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
              <h3 className="text-xl font-bold text-slate-900 dark:text-slate-100">
                {topic
                  ? "Search Results"
                  : activeMode === "for_you"
                    ? "Recommended For You"
                    : "Recent Discoveries"}
              </h3>
            </div>

            <ExploreFeed
              initialItems={items}
              initialCursor={nextCursor}
              mode={activeMode}
              topic={topic}
              sort={sort}
              trending={trending}
              signals={signals}
            />
          </div>
        </>
      )}

      <ExplorePublishButton jobs={userJobs} isAuthenticated={isAuthenticated} />
    </div>
  );
}
