"use client";

import React, { useState, useEffect, useRef, useCallback } from "react";
import Link from "next/link";
import { Heart, MessageSquare, Share2, Timer, Send, X } from "lucide-react";
import { fetchExploreAction, trackExploreEventsBatchAction } from "@/app/actions/explore";
import { likePostAction, unlikePostAction, addCommentAction } from "@/app/actions/post";

type ExploreItem = {
  id: string;
  postId?: string;
  title?: string;
  assetVersion?: {
    fileUrl?: string;
    mimeType?: string;
    durationMs?: number;
  };
  post?: {
    id?: string;
    likeCount?: number;
    commentCount?: number;
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

  const postId = item.post?.id || item.postId || item.id;
  const title = item.title || "Untitled Video";
  const mediaUrl = item.assetVersion?.fileUrl || "";
  const isVideo = isVideoSrc(mediaUrl, item.assetVersion?.mimeType);
  const authorName = item.post?.user?.username || "unknown";
  const avatarUrl =
    item.post?.user?.avatarUrl ||
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

  const [likeCount, setLikeCount] = useState(item.post?.likeCount || 0);
  const [commentCount, setCommentCount] = useState(item.post?.commentCount || 0);
  const [isLiked, setIsLiked] = useState(false);
  const [isLiking, setIsLiking] = useState(false);
  const [showCommentBox, setShowCommentBox] = useState(false);
  const [commentText, setCommentText] = useState("");
  const [isCommenting, setIsCommenting] = useState(false);

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
      videoRef.current.play().catch(() => {});
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
    if (isLiking) return;
    setIsLiking(true);
    if (isLiked) {
      setIsLiked(false);
      setLikeCount((c) => Math.max(0, c - 1));
      await unlikePostAction(postId);
    } else {
      setIsLiked(true);
      setLikeCount((c) => c + 1);
      await likePostAction(postId);
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
    if (navigator.share) navigator.share({ title, url }).catch(() => {});
    else navigator.clipboard.writeText(url);
  };

  return (
    <div
      ref={cardRef}
      className="relative bg-white border border-slate-100 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow flex flex-col group"
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <Link href={`/post/${postId}`} className="absolute inset-0 z-10" />

      {/* Media */}
      <div className="relative aspect-[4/3] bg-slate-900 overflow-hidden">
        {isVideo && mediaUrl ? (
          <video
            ref={videoRef}
            src={mediaUrl}
            className="w-full h-full object-cover"
            loop
            muted
            playsInline
            preload="metadata"
          />
        ) : (
          <img
            src={mediaUrl || fallback}
            alt={title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          />
        )}

        {/* Duration */}
        {durationMs > 0 && (
          <div className="absolute top-3 right-3 bg-black/60 backdrop-blur-sm text-white text-xs font-semibold px-2 py-1 rounded-full flex items-center gap-1 z-20 pointer-events-none">
            <Timer className="h-3 w-3" />
            {formatDuration(durationMs)}
          </div>
        )}
      </div>

      {/* Card body */}
      <div className="p-4 flex flex-col flex-1 pointer-events-none">
        <Link
          href={`/user/${authorName}`}
          className="flex items-center gap-2 mb-3 pointer-events-auto relative z-20 w-fit hover:opacity-80 transition-opacity"
        >
          <img src={avatarUrl} alt={authorName} className="h-6 w-6 rounded-full object-cover" />
          <span className="text-sm font-medium text-slate-700">{authorName}</span>
        </Link>
        <p className="text-sm text-slate-500 line-clamp-2 mb-4 flex-1">{title}</p>

        {/* Actions */}
        <div className="flex items-center justify-between text-slate-400 text-sm mt-auto border-t border-slate-50 pt-3 pointer-events-auto relative z-20">
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

          <button onClick={handleShare} className="hover:text-indigo-600 transition-colors">
            <Share2 className="h-4 w-4" />
          </button>
        </div>

        {/* Inline comment box */}
        {showCommentBox && (
          <div
            className="mt-3 pointer-events-auto relative z-20"
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
}: {
  initialItems: ExploreItem[];
  initialCursor?: string | null;
  mode: string;
}) {
  const [items, setItems] = useState<ExploreItem[]>(initialItems);
  const [cursor, setCursor] = useState<string | null | undefined>(initialCursor);
  const [isLoading, setIsLoading] = useState(false);

  const impressionQueue = useRef<string[]>([]);

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

  const loadMore = async () => {
    if (!cursor || isLoading) return;
    setIsLoading(true);
    const res = await fetchExploreAction(mode, cursor);
    if (res.success && res.data) {
      setItems((prev) => [...prev, ...(res.data.data || [])]);
      setCursor(res.data.nextCursor);
    }
    setIsLoading(false);
  };

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
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {items.map((item, idx) => (
          <ExploreCard key={item.id || idx} item={item} onImpressionTracked={handleImpressionTracked} />
        ))}
      </div>

      {cursor && (
        <div className="mt-10 mb-8 flex justify-center">
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
