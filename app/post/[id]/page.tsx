"use client";

import React, { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { useRouter, useParams } from "next/navigation";
import {
  X,
  Sparkles,
  Play,
  Pause,
  Heart,
  MessageSquare,
  Share2,
  Send,
  ChevronUp,
  ChevronDown,
  Loader2,
} from "lucide-react";
import {
  getPostAction,
  likePostAction,
  unlikePostAction,
  addCommentAction,
  fetchPostCommentsAction,
} from "@/app/actions/post";
import { trackExploreEventAction } from "@/app/actions/explore";

// ─── Types ────────────────────────────────────────────────────────────────────
// Matches GET /posts/:id response exactly per API docs
interface PostData {
  id: string;
  userId?: string;
  assetVersionId?: string;
  caption?: string | null;
  isPublic?: boolean;
  likeCount?: number;
  commentCount?: number;
  viewCount?: number;
  createdAt?: string;
  user?: {
    id?: string;
    username?: string;
    // NOTE: GET /posts/:id user object only has { id, username } — no avatarUrl
  };
  assetVersion?: {
    id?: string;
    // NOTE: assetVersion from GET /posts/:id only has { id, fileUrl, metadata }
    // No mimeType or durationMs — detect video from URL extension
    fileUrl?: string | null;
    metadata?: Record<string, unknown>;
  };
}

// Matches GET /comments response
interface Comment {
  id: string;
  content: string;
  createdAt: string;
  user?: {
    id?: string;
    username?: string;
  };
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
function timeAgo(dateStr?: string): string {
  if (!dateStr) return "";
  const diff = Date.now() - new Date(dateStr).getTime();
  const m = Math.floor(diff / 60000);
  if (m < 1) return "just now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h`;
  return `${Math.floor(h / 24)}d`;
}

function formatCount(n?: number): string {
  if (!n) return "0";
  if (n >= 1000) return `${(n / 1000).toFixed(1)}k`;
  return String(n);
}

/**
 * Detect if a URL is a video by its file extension.
 * GET /posts/:id assetVersion does NOT include mimeType, so we rely on URL extension.
 */
function isVideoUrl(url?: string | null): boolean {
  if (!url) return false;
  return /\.(mp4|webm|mov|m4v|ogg|ogv)(\?|$)/i.test(url);
}

// ─── Main Component ───────────────────────────────────────────────────────────
export default function PostDetailPage() {
  const router = useRouter();
  const params = useParams();
  const postId = params?.id as string;

  const [post, setPost] = useState<PostData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(0);
  const [isLiking, setIsLiking] = useState(false);

  const [comments, setComments] = useState<Comment[]>([]);
  const [commentText, setCommentText] = useState("");
  const [isCommenting, setIsCommenting] = useState(false);
  const [commentsNextCursor, setCommentsNextCursor] = useState<string | null>(null);
  const [isLoadingComments, setIsLoadingComments] = useState(false);

  // Animation
  const [animClass, setAnimClass] = useState("translate-y-16 opacity-0 scale-95");
  const [isNavigating, setIsNavigating] = useState(false);
  const [touchStartY, setTouchStartY] = useState<number | null>(null);
  const [touchEndY, setTouchEndY] = useState<number | null>(null);

  // Video
  const [isPlaying, setIsPlaying] = useState(false);
  const videoRef = React.useRef<HTMLVideoElement>(null);

  // ── Fetch post data using server action (carries auth token) ─────────────
  useEffect(() => {
    if (!postId) return;
    setIsLoading(true);
    setError(null);

    getPostAction(postId).then((res) => {
      if (res.success && res.data) {
        const data = res.data as PostData;
        setPost(data);
        setLikeCount(data.likeCount ?? 0);
      } else {
        setError(res.error || "Failed to load post");
      }
      setIsLoading(false);
      setAnimClass("translate-y-0 opacity-100 scale-100");
      // Track OPEN_POST — fire-and-forget
      trackExploreEventAction(postId, "OPEN_POST", { surface: "post_detail" });
    });
  }, [postId]);

  // ── Fetch comments ───────────────────────────────────────────────────────
  // NOTE: GET /comments has a route mismatch (no postId filter available).
  // We load generic paginated comments as a best-effort.
  const loadComments = useCallback(
    async (cursor?: string) => {
      if (!postId) return;
      setIsLoadingComments(true);
      const res = await fetchPostCommentsAction(postId, cursor);
      if (res.success && res.data) {
        const newItems: Comment[] = Array.isArray(res.data)
          ? res.data
          : res.data?.data || [];
        setComments((prev) => (cursor ? [...prev, ...newItems] : newItems));
        setCommentsNextCursor(res.data?.nextCursor || null);
      }
      setIsLoadingComments(false);
    },
    [postId]
  );

  useEffect(() => {
    if (postId) loadComments();
  }, [postId, loadComments]);

  // ── Like / Unlike ────────────────────────────────────────────────────────
  const handleLike = async () => {
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
      trackExploreEventAction(postId, "LIKE", { surface: "post_detail" });
    }
    setIsLiking(false);
  };

  // ── Comment ──────────────────────────────────────────────────────────────
  const handleComment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!commentText.trim() || isCommenting) return;
    setIsCommenting(true);
    const res = await addCommentAction(postId, commentText.trim());
    if (res.success && res.data) {
      // Prepend the new comment optimistically
      setComments((prev) => [res.data as Comment, ...prev]);
      setPost((p) => p ? { ...p, commentCount: (p.commentCount ?? 0) + 1 } : p);
      setCommentText("");
      trackExploreEventAction(postId, "COMMENT", { surface: "post_detail" });
    }
    setIsCommenting(false);
  };

  // ── Navigation ───────────────────────────────────────────────────────────
  const handleNavigation = (direction: "up" | "down") => {
    if (isNavigating) return;
    setIsNavigating(true);
    setAnimClass(
      direction === "up"
        ? "-translate-y-24 opacity-0 scale-95"
        : "translate-y-24 opacity-0 scale-95"
    );
    setTimeout(() => router.back(), 280);
  };

  const onTouchStart = (e: React.TouchEvent) => {
    setTouchEndY(null);
    setTouchStartY(e.targetTouches[0].clientY);
  };
  const onTouchMove = (e: React.TouchEvent) =>
    setTouchEndY(e.targetTouches[0].clientY);
  const onTouchEnd = () => {
    if (!touchStartY || !touchEndY) return;
    const dist = touchStartY - touchEndY;
    if (dist > 50) handleNavigation("up");
    else if (dist < -50) handleNavigation("down");
  };

  // ── Video play/pause ─────────────────────────────────────────────────────
  const togglePlay = () => {
    if (!videoRef.current) return;
    if (isPlaying) {
      videoRef.current.pause();
    } else {
      videoRef.current.play();
    }
  };

  // ── Share ────────────────────────────────────────────────────────────────
  const handleShare = () => {
    const url = window.location.href;
    if (navigator.share) {
      navigator.share({ title: post?.caption || "Check this out", url }).catch(() => {});
    } else {
      navigator.clipboard.writeText(url);
    }
  };

  // Derive media info
  // GET /posts/:id assetVersion = { id, fileUrl, metadata } — NO mimeType!
  const mediaUrl = post?.assetVersion?.fileUrl;
  const isVideo = isVideoUrl(mediaUrl);
  const fallbackImg =
    "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1200&auto=format&fit=crop";

  const avatarUrl = `https://ui-avatars.com/api/?name=${encodeURIComponent(
    post?.user?.username || "U"
  )}&background=e0e7ff&color=4f46e5`;

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4 sm:p-8">
      {/* Back Button */}
      <button
        onClick={() => router.back()}
        className="fixed top-6 left-6 w-10 h-10 bg-white text-indigo-900 flex items-center justify-center rounded-full hover:bg-indigo-50 transition shadow-sm border border-slate-200 z-50"
      >
        <X size={20} />
      </button>

      {/* Nav arrows */}
      <div className="fixed right-4 sm:right-6 xl:right-12 top-1/2 -translate-y-1/2 flex flex-col gap-4 z-50">
        <button
          onClick={() => handleNavigation("down")}
          className="w-10 h-10 sm:w-12 sm:h-12 bg-white text-indigo-900 flex items-center justify-center rounded-full hover:bg-indigo-50 transition shadow-lg border border-slate-200"
        >
          <ChevronUp size={24} />
        </button>
        <button
          onClick={() => handleNavigation("up")}
          className="w-10 h-10 sm:w-12 sm:h-12 bg-white text-indigo-900 flex items-center justify-center rounded-full hover:bg-indigo-50 transition shadow-lg border border-slate-200"
        >
          <ChevronDown size={24} />
        </button>
      </div>

      {/* Main Card */}
      <div
        className={`w-full max-w-[1200px] h-[85vh] min-h-[650px] bg-white rounded-[2rem] shadow-2xl flex flex-col lg:flex-row overflow-hidden border border-slate-100 relative z-10 transition-all duration-300 ease-out ${animClass}`}
      >
        {/* LEFT — Video / Image */}
        <div
          className="relative w-full lg:w-[55%] bg-black flex-shrink-0 flex items-center justify-center group cursor-pointer"
          onTouchStart={onTouchStart}
          onTouchMove={onTouchMove}
          onTouchEnd={onTouchEnd}
          onClick={isVideo ? togglePlay : undefined}
        >
          {isLoading ? (
            <Loader2 className="h-10 w-10 text-white/40 animate-spin" />
          ) : isVideo && mediaUrl ? (
            <video
              ref={videoRef}
              src={mediaUrl}
              className="absolute inset-0 w-full h-full object-cover"
              loop
              playsInline
              onPlay={() => setIsPlaying(true)}
              onPause={() => setIsPlaying(false)}
            />
          ) : (
            <img
              src={mediaUrl || fallbackImg}
              alt={post?.caption || "Post"}
              className="absolute inset-0 w-full h-full object-cover opacity-90"
            />
          )}

          <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/60 pointer-events-none" />

          {/* Badge */}
          <div className="absolute top-6 left-6 bg-white/20 backdrop-blur-md text-white/90 text-sm font-medium px-4 py-2 rounded-full flex items-center gap-2 border border-white/10 z-10">
            <Sparkles size={16} />
            <span>AI Generated</span>
          </div>

          {/* Play/Pause overlay */}
          {isVideo && !isLoading && (
            <button
              onClick={togglePlay}
              className="relative z-10 bg-white/20 backdrop-blur-md hover:bg-white/30 text-white rounded-full p-5 transition-all hover:scale-105 opacity-0 group-hover:opacity-100"
              style={{ opacity: !isPlaying ? 1 : undefined }}
            >
              {isPlaying ? (
                <Pause className="h-8 w-8 fill-current" />
              ) : (
                <Play className="h-8 w-8 fill-current ml-1" />
              )}
            </button>
          )}

          {/* Right action buttons */}
          <div className="absolute bottom-24 right-6 flex flex-col items-center gap-5 z-10">
            <div className="flex flex-col items-center gap-1.5">
              <button
                onClick={(e) => { e.stopPropagation(); handleLike(); }}
                disabled={isLiking}
                className={`w-12 h-12 backdrop-blur-sm rounded-full flex items-center justify-center transition-all ${
                  isLiked
                    ? "bg-red-500/80 text-white scale-110"
                    : "bg-black/40 text-white hover:bg-black/60"
                }`}
              >
                <Heart className={`h-6 w-6 transition-transform ${isLiked ? "fill-current scale-110" : ""}`} />
              </button>
              <span className="text-white text-xs font-semibold drop-shadow-md">
                {formatCount(likeCount)}
              </span>
            </div>

            <div className="flex flex-col items-center gap-1.5">
              <button
                onClick={(e) => e.stopPropagation()}
                className="w-12 h-12 bg-black/40 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/60 transition"
              >
                <MessageSquare className="h-6 w-6" />
              </button>
              <span className="text-white text-xs font-semibold drop-shadow-md">
                {formatCount(post?.commentCount)}
              </span>
            </div>

            <div className="flex flex-col items-center gap-1.5">
              <button
                onClick={(e) => { e.stopPropagation(); handleShare(); }}
                className="w-12 h-12 bg-black/40 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/60 transition"
              >
                <Share2 className="h-6 w-6" />
              </button>
              <span className="text-white text-xs font-semibold drop-shadow-md">Share</span>
            </div>
          </div>
        </div>

        {/* RIGHT — Info & Comments */}
        <div className="w-full lg:w-[45%] flex flex-col h-full bg-white">
          {/* Author header */}
          <div className="p-6 border-b border-slate-100 flex items-center justify-between shrink-0">
            {isLoading ? (
              <div className="flex items-center gap-3">
                <div className="w-11 h-11 rounded-full bg-slate-100 animate-pulse" />
                <div className="space-y-2">
                  <div className="h-3 w-24 bg-slate-100 rounded animate-pulse" />
                  <div className="h-2 w-16 bg-slate-100 rounded animate-pulse" />
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-3">
                <Link href={`/user/${post?.user?.username || "unknown"}`}>
                  <img
                    src={avatarUrl}
                    alt={post?.user?.username || "User"}
                    className="w-11 h-11 rounded-full object-cover bg-slate-100 cursor-pointer hover:opacity-80 transition-opacity"
                  />
                </Link>
                <div>
                  <Link
                    href={`/user/${post?.user?.username || "unknown"}`}
                    className="hover:underline"
                  >
                    <h3 className="font-semibold text-slate-900 text-sm">
                      @{post?.user?.username || "unknown"}
                    </h3>
                  </Link>
                  <p className="text-slate-500 text-xs">{timeAgo(post?.createdAt)}</p>
                </div>
              </div>
            )}
          </div>

          {/* Scrollable content */}
          <div className="flex-1 overflow-y-auto p-6 space-y-5">
            {/* Caption */}
            {isLoading ? (
              <div className="space-y-2">
                <div className="h-4 w-3/4 bg-slate-100 rounded animate-pulse" />
                <div className="h-3 w-full bg-slate-100 rounded animate-pulse" />
                <div className="h-3 w-2/3 bg-slate-100 rounded animate-pulse" />
              </div>
            ) : error ? (
              <div className="bg-red-50 text-red-600 p-3 rounded-lg text-sm border border-red-100">
                {error}
              </div>
            ) : (
              <p className="text-slate-700 text-sm leading-relaxed">
                {post?.caption || <span className="text-slate-400 italic">No caption</span>}
              </p>
            )}

            {/* Stats */}
            {!isLoading && !error && (
              <div className="flex items-center gap-4 text-sm border-b border-slate-100 pb-4">
                <span className="text-slate-900 font-semibold">
                  {formatCount(likeCount)}{" "}
                  <span className="text-slate-500 font-normal">Likes</span>
                </span>
                <span className="text-slate-900 font-semibold">
                  {formatCount(post?.commentCount)}{" "}
                  <span className="text-slate-500 font-normal">Comments</span>
                </span>
                <span className="text-slate-900 font-semibold">
                  {formatCount(post?.viewCount)}{" "}
                  <span className="text-slate-500 font-normal">Views</span>
                </span>
              </div>
            )}

            {/* Comments */}
            <div className="space-y-5">
              {isLoadingComments && comments.length === 0
                ? [1, 2, 3].map((i) => (
                    <div key={i} className="flex gap-3 animate-pulse">
                      <div className="w-8 h-8 rounded-full bg-slate-100 flex-shrink-0" />
                      <div className="flex-1 space-y-2">
                        <div className="h-3 w-20 bg-slate-100 rounded" />
                        <div className="h-3 w-full bg-slate-100 rounded" />
                      </div>
                    </div>
                  ))
                : comments.length === 0 && !isLoadingComments
                ? (
                  <p className="text-slate-400 text-sm text-center py-4">
                    No comments yet. Be the first!
                  </p>
                )
                : comments.map((comment) => (
                    <div key={comment.id} className="flex gap-3">
                      <img
                        src={`https://ui-avatars.com/api/?name=${encodeURIComponent(
                          comment.user?.username || "U"
                        )}&background=e0e7ff&color=4f46e5`}
                        alt={comment.user?.username || "user"}
                        className="w-8 h-8 rounded-full object-cover bg-slate-100 flex-shrink-0"
                      />
                      <div className="flex-1">
                        <div className="flex items-baseline gap-2 mb-1">
                          <span className="font-semibold text-slate-900 text-sm">
                            @{comment.user?.username || "unknown"}
                          </span>
                          <span className="text-slate-400 text-xs">
                            {timeAgo(comment.createdAt)}
                          </span>
                        </div>
                        <p className="text-slate-600 text-sm">{comment.content}</p>
                      </div>
                    </div>
                  ))}

              {commentsNextCursor && (
                <button
                  onClick={() => loadComments(commentsNextCursor)}
                  disabled={isLoadingComments}
                  className="w-full text-center text-indigo-600 text-sm font-medium hover:underline disabled:opacity-50 py-2"
                >
                  {isLoadingComments ? "Loading..." : "Load more comments"}
                </button>
              )}
            </div>
          </div>

          {/* Comment input */}
          <div className="p-4 sm:p-6 border-t border-slate-100 bg-white shrink-0">
            <form
              onSubmit={handleComment}
              className="flex items-center gap-3 bg-slate-100/80 border border-slate-200 rounded-full p-1.5 pr-2"
            >
              <div className="w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center ml-1 flex-shrink-0">
                <span className="text-indigo-600 text-xs font-bold">Me</span>
              </div>
              <input
                type="text"
                placeholder="Add a comment..."
                value={commentText}
                onChange={(e) => setCommentText(e.target.value)}
                className="flex-1 bg-transparent border-none focus:ring-0 text-sm px-2 text-slate-900 placeholder:text-slate-500 outline-none"
              />
              <button
                type="submit"
                disabled={!commentText.trim() || isCommenting}
                className="p-2 text-indigo-600 hover:bg-indigo-50 rounded-full transition disabled:opacity-40"
              >
                {isCommenting ? (
                  <Loader2 size={18} className="animate-spin" />
                ) : (
                  <Send size={18} />
                )}
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}