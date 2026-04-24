"use client";

import React, { useState } from "react";
import Link from "next/link";
import { Heart, MessageSquare, Share2, Timer } from "lucide-react";
import { fetchExploreAction } from "@/app/actions/explore";

export default function ExploreFeed({
  initialItems,
  initialCursor,
  mode,
}: {
  initialItems: any[];
  initialCursor?: string | null;
  mode: string;
}) {
  const [items, setItems] = useState<any[]>(initialItems);
  const [cursor, setCursor] = useState<string | null | undefined>(initialCursor);
  const [isLoading, setIsLoading] = useState(false);

  const loadMore = async () => {
    if (!cursor || isLoading) return;
    setIsLoading(true);
    
    const res = await fetchExploreAction(mode, cursor);
    if (res.success && res.data) {
      setItems(prev => [...prev, ...(res.data.data || [])]);
      setCursor(res.data.nextCursor);
    }
    
    setIsLoading(false);
  };

  const formatDuration = (ms: number) => {
    if (!ms) return "0:00";
    const totalSeconds = Math.floor(ms / 1000);
    const m = Math.floor(totalSeconds / 60);
    const s = totalSeconds % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  if (items.length === 0) {
    return (
      <div className="py-20 text-center flex flex-col items-center justify-center">
        <h4 className="text-xl font-bold text-slate-400 mb-2">No Content Yet</h4>
        <p className="text-slate-500">Check back later for new cinematic discoveries.</p>
      </div>
    );
  }

  return (
    <>
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {items.map((item: any, idx: number) => {
          const title = item.title || "Untitled Video";
          const imageUrl = item.assetVersion?.fileUrl || "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?auto=format&fit=crop&q=80&w=800";
          const authorName = item.post?.user?.username || "unknown";
          const avatarUrl = item.post?.user?.avatarUrl || "https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=100";
          const timeStr = formatDuration(item.assetVersion?.durationMs || 0);
          const likes = item.post?.likeCount || 0;
          const comments = item.post?.commentCount || 0;

          return (
            <div
              key={item.id || idx}
              className="relative bg-white border border-slate-100 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow flex flex-col block group"
            >
              <Link href={`/post/${item.id || item.postId}`} className="absolute inset-0 z-10" />
              <div className="relative aspect-[4/3]">
                <img
                  src={imageUrl}
                  alt={title}
                  className="w-full h-full object-cover"
                />
                <div className="absolute top-3 right-3 bg-white/90 backdrop-blur-sm text-slate-700 text-xs font-semibold px-2 py-1 rounded-full flex items-center gap-1 z-20">
                  <Timer className="h-3 w-3" />
                  {timeStr}
                </div>
              </div>
              <div className="p-4 flex flex-col flex-1 pointer-events-none">
                <Link href={`/user/${authorName}`} className="flex items-center gap-2 mb-3 pointer-events-auto relative z-20 w-fit hover:opacity-80 transition-opacity">
                  <img
                    src={avatarUrl}
                    alt={authorName}
                    className="h-6 w-6 rounded-full object-cover"
                  />
                  <span className="text-sm font-medium text-slate-700">
                    {authorName}
                  </span>
                </Link>
                <p className="text-sm text-slate-500 line-clamp-2 mb-4 flex-1">
                  {title}
                </p>
                <div className="flex items-center justify-between text-slate-400 text-sm mt-auto border-t border-slate-50 pt-3 pointer-events-auto relative z-20">
                  <button className="flex items-center gap-1.5 hover:text-indigo-600 transition-colors">
                    <Heart className="h-4 w-4" />
                    <span>{likes}</span>
                  </button>
                  <button className="flex items-center gap-1.5 hover:text-indigo-600 transition-colors">
                    <MessageSquare className="h-4 w-4" />
                    <span>{comments}</span>
                  </button>
                  <button className="hover:text-indigo-600 transition-colors">
                    <Share2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
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
