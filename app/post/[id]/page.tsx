"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  X,
  Sparkles,
  Play,
  Heart,
  MessageSquare,
  Share2,
  Send,
  ChevronUp,
  ChevronDown,
} from "lucide-react";

export default function PostDetailPage() {
  const router = useRouter();

  // State lưu tọa độ để tính toán hướng vuốt
  const [touchStartY, setTouchStartY] = useState<number | null>(null);
  const [touchEndY, setTouchEndY] = useState<number | null>(null);
  
  // State quản lý hiệu ứng chuyển động
  const [isNavigating, setIsNavigating] = useState(false);
  const [animationClass, setAnimationClass] = useState("translate-y-16 opacity-0 scale-95"); // Trạng thái ban đầu lúc trang mới tải

  // Chạy hiệu ứng trượt lên nhẹ khi trang bắt đầu xuất hiện
  useEffect(() => {
    setAnimationClass("translate-y-0 opacity-100 scale-100");
  }, []);

  const onTouchStart = (e: React.TouchEvent) => {
    setTouchEndY(null);
    setTouchStartY(e.targetTouches[0].clientY);
  };

  const onTouchMove = (e: React.TouchEvent) => {
    setTouchEndY(e.targetTouches[0].clientY);
  };

  const handleNextVideo = () => {
    if (isNavigating) return;
    setIsNavigating(true);
    setAnimationClass("-translate-y-24 opacity-0 scale-95"); // Hiệu ứng trượt lên
    setTimeout(() => {
      router.replace(`/post/video-${Math.floor(Math.random() * 1000)}`);
    }, 300); // Chờ 300ms cho CSS chạy xong rồi mới chuyển trang
  };

  const handlePrevVideo = () => {
    if (isNavigating) return;
    setIsNavigating(true);
    setAnimationClass("translate-y-24 opacity-0 scale-95"); // Hiệu ứng trượt xuống
    setTimeout(() => {
      router.replace(`/post/video-${Math.floor(Math.random() * 1000)}`);
    }, 300);
  };

  const onTouchEnd = () => {
    if (!touchStartY || !touchEndY) return;
    const distance = touchStartY - touchEndY;

    if (distance > 50) {
      // Vuốt lên (Khoảng cách > 50px) -> Chuyển sang Video tiếp theo
      handleNextVideo();
    } else if (distance < -50) {
      // Vuốt xuống (Khoảng cách < -50px) -> Chuyển về Video trước đó
      handlePrevVideo();
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4 sm:p-8">
      {/* Close Button */}
      <button
        onClick={() => router.back()}
        className="absolute top-6 left-6 w-10 h-10 bg-indigo-100 text-indigo-900 flex items-center justify-center rounded-full hover:bg-indigo-200 transition shadow-sm z-50"
      >
        <X size={20} />
      </button>

      {/* Navigation Buttons (Outermost Right) */}
      <div className="fixed right-4 sm:right-6 xl:right-12 top-1/2 -translate-y-1/2 flex flex-col gap-4 z-50">
        <button
          onClick={handlePrevVideo}
          className="w-10 h-10 sm:w-12 sm:h-12 bg-white text-indigo-900 flex items-center justify-center rounded-full hover:bg-indigo-50 transition shadow-lg border border-slate-200"
        >
          <ChevronUp size={24} />
        </button>
        <button
          onClick={handleNextVideo}
          className="w-10 h-10 sm:w-12 sm:h-12 bg-white text-indigo-900 flex items-center justify-center rounded-full hover:bg-indigo-50 transition shadow-lg border border-slate-200"
        >
          <ChevronDown size={24} />
        </button>
      </div>

      {/* Main Card */}
      <div className={`w-full max-w-[1200px] h-[85vh] min-h-[650px] bg-white rounded-[2rem] shadow-2xl flex flex-col lg:flex-row overflow-hidden border border-slate-100 relative z-10 transition-all duration-300 ease-out ${animationClass}`}>
        
        {/* Left Side - Video Player */}
        <div
          className="relative w-full lg:w-[55%] bg-black flex-shrink-0 flex items-center justify-center group cursor-pointer"
          onTouchStart={onTouchStart}
          onTouchMove={onTouchMove}
          onTouchEnd={onTouchEnd}
        >
          {/* Video Placeholder (Image) */}
          <img
            src="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1200&auto=format&fit=crop"
            alt="Video content"
            className="absolute inset-0 w-full h-full object-cover opacity-90"
          />
          
          {/* Gradients for readability */}
          <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/60 pointer-events-none" />

          {/* AI Generated Badge */}
          <div className="absolute top-6 left-6 bg-white/20 backdrop-blur-md text-white/90 text-sm font-medium px-4 py-2 rounded-full flex items-center gap-2 border border-white/10">
            <Sparkles size={16} />
            <span>AI Generated</span>
          </div>

          {/* Center Play Button */}
          <button className="relative bg-white/20 backdrop-blur-md hover:bg-white/30 text-white rounded-full p-5 transition-transform hover:scale-105">
            <Play className="h-8 w-8 fill-current ml-1" />
          </button>

          {/* Right Action Buttons */}
          <div className="absolute bottom-24 right-6 flex flex-col items-center gap-5">
            <div className="flex flex-col items-center gap-1.5">
              <button className="w-12 h-12 bg-black/40 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/60 transition">
                <Heart className="h-6 w-6 fill-white" />
              </button>
              <span className="text-white text-xs font-semibold drop-shadow-md">12.4k</span>
            </div>
            <div className="flex flex-col items-center gap-1.5">
              <button className="w-12 h-12 bg-black/40 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/60 transition">
                <MessageSquare className="h-6 w-6" />
              </button>
              <span className="text-white text-xs font-semibold drop-shadow-md">342</span>
            </div>
            <div className="flex flex-col items-center gap-1.5">
              <button className="w-12 h-12 bg-black/40 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/60 transition">
                <Share2 className="h-6 w-6" />
              </button>
              <span className="text-white text-xs font-semibold drop-shadow-md">Share</span>
            </div>
          </div>

          {/* Timeline/Progress */}
          <div className="absolute bottom-6 left-6 right-6 flex items-center gap-3 text-white text-xs font-medium drop-shadow-md">
            <span>0:12</span>
            <div className="flex-1 h-1.5 bg-white/30 rounded-full overflow-hidden flex">
              <div className="w-[40%] bg-indigo-500 h-full rounded-full" />
            </div>
            <span>0:30</span>
          </div>
        </div>

        {/* Right Side - Content & Comments */}
        <div className="w-full lg:w-[45%] flex flex-col h-full bg-white">
          
          {/* Header - Author */}
          <div className="p-6 border-b border-slate-100 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Link href="/user/neura_creator">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100&auto=format&fit=crop"
                  alt="Author"
                  className="w-11 h-11 rounded-full object-cover bg-slate-100 cursor-pointer hover:opacity-80 transition-opacity"
                />
              </Link>
              <div>
                <Link href="/user/neura_creator" className="hover:underline">
                  <h3 className="font-semibold text-slate-900 text-sm">@neura_creator</h3>
                </Link>
                <p className="text-slate-500 text-xs">AI Artist & Designer</p>
              </div>
            </div>
            <button className="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold px-5 py-2 rounded-full transition">
              Follow
            </button>
          </div>

          {/* Scrollable Content */}
          <div className="flex-1 overflow-y-auto p-6 space-y-6">
            {/* Post Description */}
            <div>
              <h2 className="text-slate-900 font-semibold mb-2">Ethereal Fluid Dynamics</h2>
              <p className="text-slate-600 text-sm leading-relaxed mb-2">
                Experimenting with the latest particle simulation models in Neura Gen. The way the colors blend in this generative sequence feels incredibly organic.
              </p>
              <p className="text-indigo-600 text-sm">
                #AIArt #GenerativeDesign #FluidDynamics #CreativeTech
              </p>
            </div>

            {/* Stats */}
            <div className="flex items-center gap-4 text-sm border-b border-slate-50 pb-4">
              <span className="text-slate-900 font-semibold">12.4k <span className="text-slate-500 font-normal">Likes</span></span>
              <span className="text-slate-900 font-semibold">342 <span className="text-slate-500 font-normal">Comments</span></span>
            </div>

            {/* Comments List */}
            <div className="space-y-5">
              {[
                { id: 1, author: "@design_mike", time: "2h", text: "The color grading on this is spectacular. Did you use a specific reference image for the generation?", likes: 24, avatar: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=100&auto=format&fit=crop" },
                { id: 2, author: "@creative_sarah", time: "4h", text: "Absolutely mesmerizing! Reminds me of deep sea creatures.", likes: 8, avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop" },
                { id: 3, author: "@alex_dev", time: "5h", text: "What prompt parameters did you tweak for this smoothness?", likes: 3, avatar: "https://ui-avatars.com/api/?name=A&background=e0e7ff&color=4f46e5" },
              ].map((comment) => (
                <div key={comment.id} className="flex gap-3">
                  <Link href={`/user/${comment.author.replace('@', '')}`}>
                    <img src={comment.avatar} alt={comment.author} className="w-8 h-8 rounded-full object-cover bg-slate-100 flex-shrink-0 cursor-pointer hover:opacity-80 transition-opacity" />
                  </Link>
                  <div className="flex-1">
                    <div className="flex items-baseline gap-2 mb-1">
                      <Link href={`/user/${comment.author.replace('@', '')}`} className="hover:underline">
                        <span className="font-semibold text-slate-900 text-sm">{comment.author}</span>
                      </Link>
                      <span className="text-slate-400 text-xs">{comment.time}</span>
                    </div>
                    <p className="text-slate-600 text-sm mb-1">{comment.text}</p>
                    <div className="flex items-center gap-4 text-xs text-slate-500 font-medium">
                      <button className="hover:text-slate-700">Reply</button>
                      <button className="flex items-center gap-1 hover:text-slate-700"><Heart size={14}/> {comment.likes}</button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Comment Input */}
          <div className="p-4 sm:p-6 border-t border-slate-100 bg-white">
            <div className="flex items-center gap-3 bg-slate-100/80 border border-slate-200 rounded-full p-1.5 pr-2">
              <img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=100&auto=format&fit=crop" alt="User" className="w-8 h-8 rounded-full object-cover ml-1" />
              <input type="text" placeholder="Add a comment..." className="flex-1 bg-transparent border-none focus:ring-0 text-sm px-2 text-slate-900 placeholder:text-slate-500 outline-none" />
              <button className="p-2 text-indigo-600 hover:bg-indigo-50 rounded-full transition">
                <Send size={18} />
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}