"use client";

import React, { useRef, useState } from "react";
import Link from "next/link";

export default function UserVideoCard({ post }: { post: any }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [dynamicDuration, setDynamicDuration] = useState<number | null>(null);

  const formatDuration = (ms: number) => {
    if (!ms) return "";

    const s = Math.floor(ms / 1000);
    const m = Math.floor(s / 60);

    return `${m}:${(s % 60).toString().padStart(2, "0")}`;
  };

  const handleLoadedMetadata = (
    e: React.SyntheticEvent<HTMLVideoElement>
  ) => {
    const duration = e.currentTarget.duration;

    if (duration && !isNaN(duration) && duration !== Infinity) {
      setDynamicDuration(duration);
    }
  };

  const mediaUrl =
    post.videoUrl || post.assetVersion?.fileUrl || "";

  const thumbnailUrl = post.thumbnailUrl || "";

  const isVideo =
    !!post.videoUrl ||
    post.assetVersion?.mimeType?.startsWith("video/") ||
    /\.(mp4|webm|mov|m4v)([?#]|$)/i.test(mediaUrl);

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

  return (
    <div
      className="relative aspect-[3/4] rounded-2xl overflow-hidden group cursor-pointer block"
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <Link
        href={`/post/${post.id}`}
        className="absolute inset-0 z-10"
      />

      {isVideo ? (
        <video
          ref={videoRef}
          src={mediaUrl || undefined}
          poster={thumbnailUrl || undefined}
          className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
          loop
          muted
          playsInline
          preload="metadata"
          onLoadedMetadata={handleLoadedMetadata}
        />
      ) : (
        <img
          src={
            thumbnailUrl ||
            mediaUrl ||
            "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop"
          }
          alt={post.caption || "Video thumbnail"}
          className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
      )}

      {/* Gradient overlay for readable text */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent pointer-events-none z-[1]" />

      {/* Duration */}
      {dynamicDuration && (
        <span className="absolute top-3 right-3 bg-black/50 backdrop-blur-md text-white text-xs font-semibold px-2.5 py-1 rounded-lg z-20 pointer-events-none">
          {formatDuration(Math.round(dynamicDuration * 1000))}
        </span>
      )}

      {/* Bottom content */}
      <div className="absolute bottom-4 left-4 right-4 z-20 pointer-events-none">
        <p className="text-white font-medium truncate text-sm">
          {post.caption || "Untitled"}
        </p>

        <div className="flex gap-3 text-white/80 text-xs mt-1">
          <span>{post.viewCount || 0} views</span>
          <span>{post.likeCount || 0} likes</span>
        </div>
      </div>
    </div>
  );
}
