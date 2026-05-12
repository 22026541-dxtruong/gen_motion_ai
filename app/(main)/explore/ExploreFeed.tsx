"use client";

import React, { useState, useEffect, useRef, useCallback } from "react";
import Link from "next/link";
import { Heart, MessageSquare, Share2, Timer, Send, X, Eye, MoreVertical, Sparkles, Flame } from "lucide-react";
import { fetchExploreAction, fetchExploreSearchAction, fetchExploreForYouAction, trackExploreEventsBatchAction } from "@/app/actions/explore";
import { likePostAction, unlikePostAction, addCommentAction, getPostLikeStatusAction } from "@/app/actions/post";

type ExploreItem = {
  id: string;
  postId?: string;
  title?: string;
  topic?: string;
  score?: number;
  isTrending?: boolean;
  caption?: string;
  videoUrl?: string;
  thumbnailUrl?: string;
  likeCount?: number;
  commentCount?: number;
  viewCount?: number;
  user?: {
    id: string;
    username: string;
    avatarUrl?: string;
  };
  assetVersion?: {
    fileUrl?: string;
    mimeType?: string;
    durationMs?: number;
  };
  post?: {
    id?: string;
    likeCount?: number;
    commentCount?: number;
    viewCount?: number;
    videoUrl?: string;
    thumbnailUrl?: string;
    user?: {
      id?: string;
      username?: string;
      avatarUrl?: string;
    };
  };
};

function isVideoSrc(url?: string, mimeType?: string): boolean {
  if (mimeType?.startsWith("video/")) return true;
  if (!url) return false;
  return /\.(mp4|webm|mov|m4v|ogg|ogv)(\?|$)/i.test(url);
}

// ─── ExploreCard ───────────────────────────────────────────────────────────────
function ExploreCard({
  item,
  onImpressionTracked,
}: {
  item: ExploreItem;
  onImpressionTracked: (postId: string) => void;
}) {
  const cardRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const impressionSent = useRef(false);

  // IMPORTANT: Use the actual post ID for API calls (likes, comments).
  // item.id might be the ExploreItem ID or the Post ID itself if the API returns Posts directly.
  const postId = item.postId || item.post?.id || item.id;
  const linkId = postId;
  const title = item.title || item.caption || "Untitled Video";
  // Prefer direct videoUrl/thumbnailUrl, fall back to assetVersion.fileUrl
  const videoUrl = item.videoUrl || item.post?.videoUrl || item.assetVersion?.fileUrl || "";
  const thumbnailUrl = item.thumbnailUrl || item.post?.thumbnailUrl || "";
  const mediaUrl = videoUrl || thumbnailUrl;
  const isVideo = isVideoSrc(videoUrl, item.assetVersion?.mimeType);

  const userData = item.post?.user || item.user;
  const authorName = userData?.username || "unknown";
  const authorId = userData?.id || authorName;
  const avatarUrl =
    userData?.avatarUrl ||
    `https://ui-avatars.com/api/?name=${encodeURIComponent(authorName)}&background=e0e7ff&color=4f46e5`;
  const durationMs = item.assetVersion?.durationMs || 0;
  const fallback =
    "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?auto=format&fit=crop&q=80&w=800";

  const formatDuration = (ms: number) => {
    if (!ms) return "";
    const s = Math.floor(ms / 1000);
    const m = Math.floor(s / 60);
    return `${m}:${(s % 60).toString().padStart(2, "0")}`;
  };

  const [likeCount, setLikeCount] = useState(item.post?.likeCount ?? item.likeCount ?? 0);
  const [commentCount, setCommentCount] = useState(item.post?.commentCount ?? item.commentCount ?? 0);
  const [isLiked, setIsLiked] = useState(false);
  const [isLiking, setIsLiking] = useState(false);
  const [showCommentBox, setShowCommentBox] = useState(false);
  const [commentText, setCommentText] = useState("");
  const [isCommenting, setIsCommenting] = useState(false);

  // Check if liked on mount
  useEffect(() => {
    if (postId) {
      getPostLikeStatusAction(postId).then(res => {
        setIsLiked(res.isLiked);
      });
    }
  }, [postId]);

  // Impression tracking
  useEffect(() => {
    if (!postId || impressionSent.current) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !impressionSent.current) {
          impressionSent.current = true;
          onImpressionTracked(postId);
        }
      },
      { threshold: 0.5 }
    );
    if (cardRef.current) observer.observe(cardRef.current);
    return () => observer.disconnect();
  }, [postId, onImpressionTracked]);

  // Hover-play
  const handleMouseEnter = () => {
    if (isVideo && videoRef.current) {
      videoRef.current.play().catch(() => { });
    }
  };
  const handleMouseLeave = () => {
    if (isVideo && videoRef.current) {
      videoRef.current.pause();
      videoRef.current.currentTime = 0;
    }
  };

  const handleLike = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (isLiking || !postId) return;
    setIsLiking(true);
    if (isLiked) {
      setIsLiked(false);
      setLikeCount((c) => Math.max(0, c - 1));
      const res = await unlikePostAction(postId);
      if (!res.success) {
        // Revert optimistic update on failure
        setIsLiked(true);
        setLikeCount((c) => c + 1);
      }
    } else {
      setIsLiked(true);
      setLikeCount((c) => c + 1);
      const res = await likePostAction(postId);
      if (!res.success) {
        // Revert optimistic update on failure
        setIsLiked(false);
        setLikeCount((c) => Math.max(0, c - 1));
      }
    }
    setIsLiking(false);
  };

  const handleCommentToggle = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setShowCommentBox((v) => !v);
  };

  const handleSubmitComment = async (e: React.MouseEvent | React.KeyboardEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!commentText.trim() || isCommenting) return;
    setIsCommenting(true);
    const res = await addCommentAction(postId, commentText.trim());
    if (res.success) {
      setCommentCount((c) => c + 1);
      setCommentText("");
      setShowCommentBox(false);
    }
    setIsCommenting(false);
  };

  const handleShare = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    const url = `${window.location.origin}/post/${postId}`;
    if (navigator.share) navigator.share({ title, url }).catch(() => { });
    else navigator.clipboard.writeText(url);
  };

  return (
    <div
      ref={cardRef}
      className="bg-white rounded-3xl overflow-hidden shadow-sm hover:shadow-md transition group flex flex-col relative"
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <Link href={`/post/${linkId}`} className="absolute inset-0 z-10" />

      {/* Media */}
      <div className="relative h-48 bg-slate-900 overflow-hidden group">

        {/* Badges */}
        <div className="absolute top-3 left-3 flex flex-wrap gap-2 z-20 pointer-events-none">
          {item.isTrending && (
            <span className="bg-orange-500/90 backdrop-blur-sm text-white text-[10px] font-bold px-2 py-1 rounded-md uppercase tracking-wider shadow-sm flex items-center gap-1">
              <Flame size={12} /> Trending
            </span>
          )}
          {item.topic && item.topic !== 'general' && (
            <span className="bg-black/50 backdrop-blur-sm text-white text-[10px] font-bold px-2 py-1 rounded-md uppercase tracking-wider shadow-sm">
              {item.topic}
            </span>
          )}
        </div>

        {/* Video Player */}
        {isVideo && videoUrl ? (
          <video
            ref={videoRef}
            src={videoUrl}
            poster={thumbnailUrl || fallback}
            className="absolute inset-0 w-full h-full object-cover z-0 transition-transform duration-500 group-hover:scale-105"
            loop
            muted
            playsInline
            preload="metadata"
          />
        ) : (
          <img
            src={mediaUrl || fallback}
            alt={title}
            className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 z-0 group-hover:scale-105"
          />
        )}

        {/* Duration */}
        {durationMs > 0 && (
          <span className="absolute bottom-3 right-3 bg-black/60 backdrop-blur-md text-white text-xs font-semibold px-2.5 py-1 rounded-lg z-20 pointer-events-none">
            {formatDuration(durationMs)}
          </span>
        )}
      </div>

      {/* Card body */}
      <div className="p-5 flex flex-col flex-1 pointer-events-none">
        <div className="flex justify-between items-start mb-3">
          <h3 className="font-semibold text-gray-900 truncate pr-4 text-lg flex-1">
            {title}
          </h3>
          <button className="text-gray-400 hover:text-gray-700 mt-1 pointer-events-auto relative z-20">
            <MoreVertical size={18} />
          </button>
        </div>

        <Link
          href={`/user/${authorId}`}
          className="flex items-center gap-2 mb-4 pointer-events-auto relative z-20 w-fit hover:opacity-80 transition-opacity"
        >
          <img src={avatarUrl} alt={authorName} className="h-6 w-6 rounded-full object-cover" />
          <span className="text-sm font-medium text-gray-600">@{authorName}</span>
        </Link>

        {/* Actions */}
        <div className="flex items-center justify-between mt-auto pt-2 pointer-events-auto relative z-20">
          <div className="flex items-center gap-4 text-sm font-medium text-gray-500">
            <span className="flex items-center gap-1.5">
              <Eye size={16} /> {item.viewCount ?? item.post?.viewCount ?? 0}
            </span>
            <button
              onClick={handleLike}
              disabled={isLiking}
              className={`flex items-center gap-1.5 transition-colors ${isLiked ? "text-red-500" : "hover:text-indigo-600"}`}
            >
              <Heart className={`h-4 w-4 transition-transform ${isLiked ? "fill-red-500 scale-110" : ""}`} />
              <span>{likeCount}</span>
            </button>

            <button
              onClick={handleCommentToggle}
              className="flex items-center gap-1.5 hover:text-indigo-600 transition-colors"
            >
              <MessageSquare className="h-4 w-4" />
              <span>{commentCount}</span>
            </button>
          </div>

          <button onClick={handleShare} className="text-gray-400 hover:text-indigo-600 transition-colors">
            <Share2 className="h-4 w-4" />
          </button>
        </div>

        {/* Inline comment box */}
        {showCommentBox && (
          <div
            className="mt-4 pointer-events-auto relative z-20"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center gap-2 border border-slate-200 rounded-xl bg-slate-50 px-3 py-1.5">
              <input
                type="text"
                value={commentText}
                onChange={(e) => setCommentText(e.target.value)}
                onKeyDown={(e) => { if (e.key === "Enter") handleSubmitComment(e); }}
                placeholder="Write a comment..."
                className="flex-1 bg-transparent outline-none text-sm text-slate-800 placeholder:text-slate-400"
                autoFocus
              />
              <button
                onClick={handleSubmitComment}
                disabled={!commentText.trim() || isCommenting}
                className="text-indigo-600 disabled:opacity-40 hover:text-indigo-700"
              >
                <Send className="h-4 w-4" />
              </button>
              <button onClick={handleCommentToggle} className="text-slate-400 hover:text-slate-600">
                <X className="h-4 w-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── ExploreFeed ──────────────────────────────────────────────────────────────
export default function ExploreFeed({
  initialItems,
  initialCursor,
  mode,
  topic,
  sort,
  trending,
  signals
}: {
  initialItems: ExploreItem[];
  initialCursor?: string | null;
  mode: string;
  topic?: string;
  sort?: string;
  trending?: boolean;
  signals?: any;
}) {
  const [items, setItems] = useState<ExploreItem[]>(initialItems);
  const [cursor, setCursor] = useState<string | null | undefined>(initialCursor);
  const [isLoading, setIsLoading] = useState(false);

  // If initialItems changes (e.g. user toggles sort/mode), reset state
  useEffect(() => {
    setItems(initialItems);
    setCursor(initialCursor);
  }, [initialItems, initialCursor]);

  // Save current feed to session storage for infinite swiping in post detail
  useEffect(() => {
    if (items.length > 0) {
      const feedContext = {
        items: items.map(item => item.postId || item.post?.id || item.id),
        cursor,
        mode,
        topic,
        sort,
        trending
      };
      sessionStorage.setItem('motion_explore_feed', JSON.stringify(feedContext));
    }
  }, [items, cursor, mode, topic, sort, trending]);

  const impressionQueue = useRef<string[]>([]);
  const loadMoreRef = useRef<HTMLDivElement>(null);

  const handleImpressionTracked = useCallback((postId: string) => {
    if (!impressionQueue.current.includes(postId)) {
      impressionQueue.current.push(postId);
    }
  }, []);

  useEffect(() => {
    const interval = setInterval(async () => {
      if (impressionQueue.current.length === 0) return;
      const batch = impressionQueue.current.splice(0);
      await trackExploreEventsBatchAction(
        batch.map((postId) => ({ postId, eventType: "IMPRESSION", metadata: { surface: "explore_grid" } }))
      );
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const loadMore = useCallback(async () => {
    if (!cursor || isLoading) return;
    setIsLoading(true);

    let res;
    if (mode === 'for_you') {
      res = await fetchExploreForYouAction({ topic, limit: 10, cursor });
    } else if (topic) {
      res = await fetchExploreSearchAction(topic, { cursor, sort, trending });
    } else {
      res = await fetchExploreAction(mode, { cursor, topic, sort, trending });
    }

    if (res.success && res.data) {
      setItems((prev) => {
        const newItems = (res.data.data || []).filter(
          (ni: ExploreItem) => !prev.some((pi) => pi.id === ni.id)
        );
        return [...prev, ...newItems];
      });
      setCursor(res.data.nextCursor);
    }
    setIsLoading(false);
  }, [cursor, isLoading, mode, topic, sort, trending]);

  useEffect(() => {
    const currentObserver = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && cursor && !isLoading) {
          loadMore();
        }
      },
      { rootMargin: "200px" } // Load earlier for better UX
    );

    if (loadMoreRef.current) {
      currentObserver.observe(loadMoreRef.current);
    }

    return () => currentObserver.disconnect();
  }, [cursor, isLoading, loadMore]);

  if (items.length === 0) {
    return (
      <div className="py-20 text-center">
        <h4 className="text-xl font-bold text-slate-400 mb-2">No Content Yet</h4>
        <p className="text-slate-500">Check back later for new cinematic discoveries.</p>
      </div>
    );
  }

  return (
    <>
      {signals && (
        <div className="mb-6 p-4 bg-indigo-50 border border-indigo-100 rounded-2xl flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-indigo-100 text-indigo-600 rounded-xl">
              <Sparkles size={20} />
            </div>
            <div>
              <p className="text-sm font-medium text-slate-800">
                Personalized for you based on your interests.
              </p>
              {signals.topTopics && signals.topTopics.length > 0 && (
                <p className="text-xs text-slate-500 mt-0.5">
                  Top Topics: {signals.topTopics.map((t: any) => t.topic).join(', ')}
                </p>
              )}
            </div>
          </div>
        </div>
      )}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {items.map((item, idx) => (
          <ExploreCard key={item.id || idx} item={item} onImpressionTracked={handleImpressionTracked} />
        ))}
      </div>

      {cursor && (
        <div ref={loadMoreRef} className="mt-10 mb-8 flex justify-center">
          <button
            onClick={loadMore}
            disabled={isLoading}
            className="bg-indigo-50 text-indigo-600 px-8 py-3 rounded-xl font-medium hover:bg-indigo-100 transition-colors disabled:opacity-50"
          >
            {isLoading ? "Loading..." : "Load More Content"}
          </button>
        </div>
      )}
    </>
  );
}
