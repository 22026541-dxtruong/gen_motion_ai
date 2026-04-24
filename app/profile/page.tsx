"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  Share2,
  Globe,
  Lock,
  ListFilter,
  Zap,
  Eye,
  Heart,
  MoreVertical,
} from "lucide-react";
import MainLayout from "../../component/MainLayout";
import Dialog from "../../component/Dialog";

const galleryItems = [
  {
    id: 1,
    title: "Neon Dreams: Tokyo 2077",
    duration: "0:15",
    views: "2.4k",
    likes: "142",
    tag: "CYBERPUNK",
    tagColor: "bg-blue-50 text-blue-600",
    image:
      "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=600&auto=format&fit=crop",
  },
  {
    id: 2,
    title: "Sahara Golden Hour...",
    duration: "0:24",
    views: "890",
    likes: "56",
    tag: "REALISTIC",
    tagColor: "bg-orange-50 text-orange-600",
    image:
      "https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=600&auto=format&fit=crop",
  },
  {
    id: 3,
    title: "Abyssal Bioluminescence...",
    duration: "0:12",
    views: "4.1k",
    likes: "312",
    tag: "SCI-FI",
    tagColor: "bg-indigo-50 text-indigo-600",
    image:
      "https://images.unsplash.com/photo-1582967788606-a171c1080cb0?q=80&w=600&auto=format&fit=crop",
  },
];

const followersList = [
  {
    id: 1,
    name: "Elena Rodriguez",
    handle: "@elena_creates",
    isFollowing: true,
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100&auto=format&fit=crop",
  },
  {
    id: 2,
    name: "Marcus Chen",
    handle: "@marcus_vfx",
    isFollowing: false,
    avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=100&auto=format&fit=crop",
  },
  {
    id: 3,
    name: "Sarah Jenkins",
    handle: "@sarahj_ai",
    isFollowing: false,
    avatar: "",
    initial: "S",
    color: "bg-[#7b51ea]",
  },
  {
    id: 4,
    name: "Aisha Patel",
    handle: "@aishavision",
    isFollowing: true,
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop",
  },
  {
    id: 5,
    name: "David Kim",
    handle: "@dkim_renders",
    isFollowing: false,
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop",
  },
  {
    id: 6,
    name: "Neo Tokyo",
    handle: "@cyber_neo",
    isFollowing: false,
    avatar: "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?q=80&w=100&auto=format&fit=crop",
  },
];

export default function ProfilePage() {
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isFollowersDialogOpen, setIsFollowersDialogOpen] = useState(false);

  return (
    <MainLayout activePage="profile">
      <div className="max-w-6xl mx-auto p-6 space-y-8 animate-in fade-in duration-500">
        {/* Banner & Header Section */}
        <div className="relative">
          {/* Banner */}
          <div className="h-56 w-full rounded-3xl bg-gradient-to-r from-gray-200 via-indigo-200 to-purple-300 overflow-hidden relative">
            <img
              src="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop"
              alt="Banner"
              className="w-full h-full object-cover mix-blend-overlay opacity-60"
            />
          </div>

          {/* Profile Info */}
          <div className="px-8 flex justify-between items-start">
            <div className="flex gap-6">
              <div className="-mt-14 relative z-10">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop"
                  alt="Alex Rivera"
                  className="w-32 h-32 rounded-2xl border-4 border-white shadow-sm object-cover bg-gray-100"
                />
              </div>
              <div className="pt-4">
                <h1 className="text-3xl font-bold text-gray-900">
                  Alex Rivera
                </h1>
                <p className="text-gray-600 mt-1">
                  @arivera_vision • Senior AI Prompt Engineer & Motion Designer
                </p>
              </div>
            </div>
            <div className="pt-4 flex gap-3">
              <button 
                onClick={() => setIsEditDialogOpen(true)}
                className="bg-indigo-600 text-white px-6 py-2.5 rounded-full font-medium hover:bg-indigo-700 transition shadow-sm"
              >
                Edit Profile
              </button>
              <button className="p-2.5 rounded-full border border-gray-200 hover:bg-gray-50 text-gray-700 transition">
                <Share2 size={20} />
              </button>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-4 gap-4 pt-4">
          {[
            { label: "FOLLOWERS", value: "12.8k", color: "text-indigo-600", onClick: () => setIsFollowersDialogOpen(true) },
            { label: "FOLLOWING", value: "432", color: "text-gray-900" },
            { label: "POSTS", value: "156", color: "text-gray-900" },
            { label: "JOBS", value: "24", color: "text-purple-600" },
          ].map((stat) => (
            <div
              key={stat.label}
              onClick={stat.onClick}
              className={`bg-white p-6 rounded-2xl shadow-sm flex flex-col justify-center ${stat.onClick ? "cursor-pointer hover:shadow-md transition" : ""}`}
            >
              <span className="text-xs font-semibold text-gray-500 tracking-wider">
                {stat.label}
              </span>
              <span className={`text-3xl font-bold mt-1 ${stat.color}`}>
                {stat.value}
              </span>
            </div>
          ))}
        </div>

        {/* Bio */}
        <p className="text-gray-700 leading-relaxed text-lg pt-2">
          Pushing the boundaries of generative storytelling. Focused on
          cinematic realism and futuristic architecture. Open for collaborations
          on high-end commercial AI video projects. ✨
        </p>

        {/* Credits Section */}
        <div className="bg-white rounded-3xl p-6 flex items-center justify-between shadow-sm">
          <div className="flex items-center gap-5">
            <div className="w-14 h-14 bg-indigo-600 rounded-2xl flex items-center justify-center text-white shadow-md shadow-indigo-200">
              <Zap size={24} className="fill-current" />
            </div>
            <div>
              <p className="text-xs font-semibold text-gray-500 tracking-wider">
                CREDIT BALANCE
              </p>
              <div className="flex items-baseline gap-2 mt-1">
                <span className="text-3xl font-bold text-gray-900">1,240</span>
                <span className="text-sm text-gray-500 font-medium">
                  / 2,000 this month
                </span>
              </div>
            </div>
          </div>
          <button className="bg-indigo-50 text-indigo-700 px-6 py-3 rounded-full font-semibold hover:bg-indigo-100 transition">
            Buy Credits
          </button>
        </div>

        {/* Tabs & Filters */}
        <div className="flex items-center justify-between border-b border-gray-200 pt-4">
          <div className="flex gap-8">
            <button className="flex items-center gap-2 text-indigo-600 border-b-2 border-indigo-600 pb-4 font-medium px-1">
              <Globe size={18} /> Public Gallery
            </button>
            <button className="flex items-center gap-2 text-gray-500 pb-4 font-medium px-1 hover:text-gray-700 transition">
              <Lock size={18} /> Private Workspace
            </button>
          </div>
          <button className="flex items-center gap-2 text-gray-500 pb-4 font-medium hover:text-gray-800 transition">
            <ListFilter size={18} /> Filter
          </button>
        </div>

        {/* Gallery Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 pt-4">
          {galleryItems.map((item) => (
            <Link
              href={`/post/${item.id}`}
              key={item.id}
              className="bg-white rounded-3xl overflow-hidden shadow-sm hover:shadow-md transition cursor-pointer group block"
            >
              <div className="relative h-48 bg-gray-100">
                <img
                  src={item.image}
                  alt={item.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition duration-500"
                />
                <span className="absolute bottom-3 right-3 bg-black/60 backdrop-blur-md text-white text-xs font-semibold px-2.5 py-1 rounded-lg">
                  {item.duration}
                </span>
              </div>
              <div className="p-5">
                <div className="flex justify-between items-start">
                  <h3 className="font-semibold text-gray-900 truncate pr-4 text-lg">
                    {item.title}
                  </h3>
                  <button className="text-gray-400 hover:text-gray-700 mt-1">
                    <MoreVertical size={18} />
                  </button>
                </div>
                <div className="flex items-center justify-between mt-4">
                  <div className="flex items-center gap-4 text-sm font-medium text-gray-500">
                    <span className="flex items-center gap-1.5">
                      <Eye size={16} /> {item.views}
                    </span>
                    <span className="flex items-center gap-1.5">
                      <Heart size={16} /> {item.likes}
                    </span>
                  </div>
                  <span
                    className={`text-[10px] font-bold tracking-wider px-2.5 py-1.5 rounded-lg uppercase ${item.tagColor}`}
                  >
                    {item.tag}
                  </span>
                </div>
              </div>
            </Link>
          ))}
        </div>

        {/* Edit Profile Dialog */}
        <Dialog
          isOpen={isEditDialogOpen}
          onClose={() => setIsEditDialogOpen(false)}
          title="Edit Profile"
        >
          <div className="space-y-5">
            <div className="flex flex-col items-center gap-2">
              <img
                src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop"
                alt="Profile"
                className="w-24 h-24 rounded-full object-cover shadow-sm"
              />
              <button className="text-sm text-indigo-600 font-medium hover:text-indigo-700 transition">
                Change Photo
              </button>
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1.5">Username</label>
              <input
                type="text"
                defaultValue="Alex Mercer"
                className="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:border-indigo-600 focus:ring-1 focus:ring-indigo-600 transition text-gray-900"
              />
            </div>
            <div>
              <div className="flex justify-between items-center mb-1.5">
                <label className="block text-sm font-semibold text-gray-900">Bio</label>
                <span className="text-xs text-gray-500">64/150</span>
              </div>
              <textarea
                rows={3}
                defaultValue="Digital creator & AI Enthusiast | Exploring the latent space."
                className="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:border-indigo-600 focus:ring-1 focus:ring-indigo-600 transition resize-none text-gray-900"
              />
            </div>
            <div className="flex justify-center gap-4 mt-8 pt-4 border-t border-gray-100">
              <button onClick={() => setIsEditDialogOpen(false)} className="px-6 py-2 border border-indigo-600 text-indigo-600 hover:bg-indigo-50 rounded-full font-medium transition">
                Cancel
              </button>
              <button onClick={() => setIsEditDialogOpen(false)} className="px-6 py-2 bg-indigo-600 text-white rounded-full font-medium hover:bg-indigo-700 transition shadow-sm">
                Save Changes
              </button>
            </div>
          </div>
        </Dialog>

        {/* Followers Dialog */}
        <Dialog
          isOpen={isFollowersDialogOpen}
          onClose={() => setIsFollowersDialogOpen(false)}
          title="Followers"
        >
          <div className="flex flex-col gap-5 max-h-[60vh] overflow-y-auto pr-2">
            {followersList.map((user) => (
              <div key={user.id} className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  {user.avatar ? (
                    <img src={user.avatar} alt={user.name} className="w-12 h-12 rounded-full object-cover shadow-sm" />
                  ) : (
                    <div className={`w-12 h-12 rounded-full flex items-center justify-center text-white text-lg font-medium shadow-sm ${user.color}`}>
                      {user.initial}
                    </div>
                  )}
                  <div>
                    <h4 className="font-semibold text-gray-900 text-base">{user.name}</h4>
                    <p className="text-gray-500 text-sm">{user.handle}</p>
                  </div>
                </div>
                <button
                  className={`px-5 py-1.5 rounded-full text-sm font-medium transition-colors ${
                    user.isFollowing
                      ? "border border-gray-400 text-gray-700 hover:bg-gray-50"
                      : "bg-[#5e38f4] text-white hover:bg-[#4b2bd6]"
                  }`}
                >
                  {user.isFollowing ? "Following" : "Follow"}
                </button>
              </div>
            ))}
          </div>
        </Dialog>
      </div>
    </MainLayout>
  );
}
