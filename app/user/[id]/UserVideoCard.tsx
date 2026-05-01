"use client";

import React, { useRef } from "react";
import Link from "next/link";
import { Play } from "lucide-react";

export default function UserVideoCard({ post }: { post: any }) {
  const videoRef = useRef<HTMLVideoElement>(null);

  const mediaUrl = post.videoUrl || post.assetVersion?.fileUrl || "";
  const thumbnailUrl = post.thumbnailUrl || "";
  const isVideo = !!post.videoUrl || post.assetVersion?.mimeType?.startsWith("video/") || /\.(mp4|webm|mov|m4v)([?#]|$)/i.test(mediaUrl);

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
      className="relative aspect-[3/4] bg-[#111] rounded-2xl overflow-hidden group cursor-pointer block"
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <Link href={`/post/${post.id}`} className="absolute inset-0 z-10" />
      
      {isVideo ? (
        <video
          ref={videoRef}
          src={mediaUrl || undefined}
          poster={thumbnailUrl || undefined}
          className="absolute inset-0 w-full h-full object-cover opacity-80 mix-blend-overlay group-hover:scale-105 group-hover:opacity-100 transition-all duration-500"
          loop
          muted
          playsInline
          preload="metadata"
        />
      ) : (
        <img
          src={thumbnailUrl || mediaUrl || "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop"}
          alt={post.caption || "Video thumbnail"}
          className="w-full h-full object-cover opacity-80 mix-blend-overlay group-hover:scale-105 group-hover:opacity-100 transition-all duration-500"
        />
      )}
      
      <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent pointer-events-none"></div>
      
      <Play className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-16 h-16 text-white/90 group-hover:scale-110 transition-transform fill-white/20 pointer-events-none" />
      
      <div className="absolute bottom-4 left-4 right-4 z-20 pointer-events-none">
        <p className="text-white font-medium truncate text-sm">
          {post.caption || "Untitled"}
        </p>
        <div className="flex gap-3 text-white/70 text-xs mt-1">
          <span>{post.viewCount || 0} views</span>
          <span>{post.likeCount || 0} likes</span>
        </div>
      </div>
    </div>
  );
}
