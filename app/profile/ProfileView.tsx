"use client";

import React, { useState, useRef } from "react";
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
  Send,
  Loader2,
} from "lucide-react";
import Dialog from "../../component/Dialog";
import PublishDialog from "../../component/PublishDialog";
import { updateUserProfileAction } from "@/app/actions/user";
import { uploadAssetAction } from "@/app/actions/job";
import FollowsModal from "../component/FollowsModal";

// ─── GalleryCard — video plays on hover ──────────────────────────────────────
function GalleryCard({
  item,
  idx,
  mediaUrl,
  isVideo,
  formatDuration,
  onPublish,
}: {
  item: any;
  idx: number;
  mediaUrl: string;
  isVideo: boolean;
  formatDuration: (ms: number) => string;
  onPublish: (item: any) => void;
}) {
  const videoRef = useRef<HTMLVideoElement>(null);

  const assetVersion = item.assetVersion || {};

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

  return (
    <div
      className="bg-white rounded-3xl overflow-hidden shadow-sm hover:shadow-md transition group block relative"
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <Link
        href={item.isJob ? "#" : `/post/${item.id}`}
        className="absolute inset-0 z-10"
      />
      <div className="relative h-48 bg-slate-900 overflow-hidden">
        {isVideo ? (
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
            src={mediaUrl}
            alt={item.title || "Thumbnail"}
            className="w-full h-full object-cover group-hover:scale-105 transition duration-500"
          />
        )}
        <span className="absolute bottom-3 right-3 bg-black/60 backdrop-blur-md text-white text-xs font-semibold px-2.5 py-1 rounded-lg z-20">
          {formatDuration(assetVersion.durationMs || 0)}
        </span>
      </div>
      <div className="p-5">
        <div className="flex justify-between items-start">
          <h3 className="font-semibold text-gray-900 truncate pr-4 text-lg">
            {item.title || item.caption || "Untitled Video"}
          </h3>
          <button className="text-gray-400 hover:text-gray-700 mt-1">
            <MoreVertical size={18} />
          </button>
        </div>
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center gap-4 text-sm font-medium text-gray-500">
            <span className="flex items-center gap-1.5">
              <Eye size={16} /> {item.viewCount ?? item.post?.viewCount ?? 0}
            </span>
            <span className="flex items-center gap-1.5">
              <Heart size={16} /> {item.likeCount ?? item.post?.likeCount ?? 0}
            </span>
          </div>
          {(!item.isPublic || item.isJob) && (
            <button
              onClick={(e) => {
                e.preventDefault();
                e.stopPropagation();
                onPublish(item);
              }}
              className="relative z-20 flex items-center gap-1.5 text-xs font-semibold bg-indigo-50 text-indigo-600 px-3 py-1.5 rounded-lg hover:bg-indigo-100 transition-colors ml-auto"
            >
              <Send size={14} /> Publish
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── ProfileView ──────────────────────────────────────────────────────────────
export default function ProfileView({
  userProfile,
  galleryItems,
  jobs,
}: {
  userProfile: any;
  galleryItems: any[];
  jobs?: any[];
}) {
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isFollowersDialogOpen, setIsFollowersDialogOpen] = useState(false);
  const [isFollowingsDialogOpen, setIsFollowingsDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<"public" | "private">("public");

  // Avatar Upload State
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false);
  const [avatarPreview, setAvatarPreview] = useState<string | null>(null);

  // Publish Dialog State
  const [publishingItem, setPublishingItem] = useState<any>(null);

  const [isUpdating, setIsUpdating] = useState(false);
  const [updateError, setUpdateError] = useState<string | null>(null);

  const displayedGallery =
    activeTab === "public"
      ? galleryItems.filter((item) => item.isPublic)
      : (
        jobs
          ?.filter((j: any) => j.status === "COMPLETED")
          .map((job: any) => ({
            id: job.id,
            title: job.prompt || "Video Generation",
            isJob: true,
            assetVersion: {
              fileUrl: job.output?.downloadUrl || job.thumbnail?.downloadUrl || job.assets?.[0]?.versions?.[0]?.fileUrl,
              durationMs: job.estimatedDurationSeconds
                ? job.estimatedDurationSeconds * 1000
                : 0,
            },
            post: { viewCount: 0, likeCount: 0 },
          })) || []
      );

  const handleUpdateProfile = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsUpdating(true);
    setUpdateError(null);
    const formData = new FormData(e.currentTarget);

    try {
      const payload: any = {
        username: formData.get("username") as string,
        bio: formData.get("bio") as string,
      };
      if (avatarPreview && avatarPreview.startsWith("http")) {
        payload.avatarUrl = avatarPreview;
      }

      const res = await updateUserProfileAction(payload);
      if (!res.success) throw new Error(res.error);
      setIsEditDialogOpen(false);
    } catch (err: any) {
      setUpdateError(err.message);
    } finally {
      setIsUpdating(false);
    }
  };

  const handleAvatarFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploadingAvatar(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await uploadAssetAction(formData);
      if (res.success && res.asset?.versions?.[0]?.fileUrl) {
        setAvatarPreview(res.asset.versions[0].fileUrl);
      } else {
        alert("Failed to upload avatar: " + (res.error || "Unknown error"));
      }
    } catch (err) {
      alert("Error uploading file");
    } finally {
      setIsUploadingAvatar(false);
    }
  };

  const formatDuration = (ms: number) => {
    if (!ms) return "0:00";
    const totalSeconds = Math.floor(ms / 1000);
    const m = Math.floor(totalSeconds / 60);
    const s = totalSeconds % 60;
    return `${m}:${s.toString().padStart(2, "0")}`;
  };

  return (
    <div className="max-w-6xl mx-auto p-6 space-y-8 animate-in fade-in duration-500">
      {/* Banner & Header Section */}
      <div className="relative">
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
                src={
                  userProfile?.avatarUrl ||
                  `https://ui-avatars.com/api/?name=${encodeURIComponent(userProfile?.username || "User")}&background=e0e7ff&color=4f46e5`
                }
                alt={userProfile?.username || "User"}
                className="w-32 h-32 rounded-2xl border-4 border-white shadow-sm object-cover bg-gray-100"
              />
            </div>
            <div className="pt-4">
              <h1 className="text-3xl font-bold text-gray-900">
                {userProfile?.username || "Unknown User"}
              </h1>
              <p className="text-gray-600 mt-1">
                @{userProfile?.username || "unknown"} • Creator
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
          {
            label: "FOLLOWERS",
            value: userProfile?.counts?.followers || 0,
            color: "text-indigo-600",
            onClick: () => setIsFollowersDialogOpen(true),
          },
          {
            label: "FOLLOWING",
            value: userProfile?.counts?.following || 0,
            color: "text-gray-900",
            onClick: () => setIsFollowingsDialogOpen(true),
          },
          {
            label: "POSTS",
            value: userProfile?.counts?.posts || 0,
            color: "text-gray-900",
          },
          {
            label: "JOBS",
            value: userProfile?.counts?.jobs || 0,
            color: "text-purple-600",
          },
        ].map((stat) => (
          <div
            key={stat.label}
            onClick={stat.onClick}
            className={`bg-white p-6 rounded-2xl shadow-sm flex flex-col justify-center ${stat.onClick ? "cursor-pointer hover:shadow-md transition" : ""
              }`}
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
        {userProfile?.bio || "No bio yet. Update your profile to add one! ✨"}
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
              <span className="text-3xl font-bold text-gray-900">
                {userProfile?.credits?.balance || 0}
              </span>
              <span className="text-sm text-gray-500 font-medium">
                Available Credits
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
          <button
            onClick={() => setActiveTab("public")}
            className={`flex items-center gap-2 pb-4 font-medium px-1 transition ${activeTab === "public"
                ? "text-indigo-600 border-b-2 border-indigo-600"
                : "text-gray-500 hover:text-gray-700"
              }`}
          >
            <Globe size={18} /> Public Gallery
          </button>
          <button
            onClick={() => setActiveTab("private")}
            className={`flex items-center gap-2 pb-4 font-medium px-1 transition ${activeTab === "private"
                ? "text-indigo-600 border-b-2 border-indigo-600"
                : "text-gray-500 hover:text-gray-700"
              }`}
          >
            <Lock size={18} /> Private Workspace
          </button>
        </div>
        <button className="flex items-center gap-2 text-gray-500 pb-4 font-medium hover:text-gray-800 transition">
          <ListFilter size={18} /> Filter
        </button>
      </div>

      {/* Gallery Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 pt-4">
        {displayedGallery.length === 0 ? (
          <div className="col-span-full py-10 text-center text-slate-500">
            No items found in{" "}
            {activeTab === "public" ? "public gallery" : "private workspace"}.
          </div>
        ) : (
          displayedGallery.map((item: any, idx: number) => {
            const assetVersion = item.assetVersion || {};
            const mediaUrl =
              item.videoUrl || item.thumbnailUrl || assetVersion.fileUrl ||
              "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=600&auto=format&fit=crop";
            const isVideo =
              !!item.videoUrl ||
              assetVersion.mimeType?.startsWith("video/") ||
              /\.(mp4|webm|mov|m4v)([?#]|$)/i.test(mediaUrl);
            return (
              <GalleryCard
                key={item.id}
                item={item}
                idx={idx}
                mediaUrl={mediaUrl}
                isVideo={isVideo}
                formatDuration={formatDuration}
                onPublish={setPublishingItem}
              />
            );
          })
        )}
      </div>

      {/* Publish Dialog */}
      {publishingItem && (
        <PublishDialog
          isOpen={!!publishingItem}
          onClose={() => setPublishingItem(null)}
          assetId={publishingItem.isJob ? publishingItem.id : null}
          assetVersionId={publishingItem.assetVersion?.id}
          defaultCaption={publishingItem.title}
        />
      )}

      {/* Edit Profile Dialog */}
      <Dialog
        isOpen={isEditDialogOpen}
        onClose={() => setIsEditDialogOpen(false)}
        title="Edit Profile"
      >
        <form onSubmit={handleUpdateProfile} className="space-y-5">
          {updateError && (
            <div className="p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100">
              {updateError}
            </div>
          )}
          <div className="flex flex-col items-center gap-2">
            <div className="relative">
              <img
                src={
                  avatarPreview ||
                  userProfile?.avatarUrl ||
                  `https://ui-avatars.com/api/?name=${encodeURIComponent(userProfile?.username || "User")}&background=e0e7ff&color=4f46e5`
                }
                alt="Profile"
                className={`w-24 h-24 rounded-full object-cover shadow-sm ${isUploadingAvatar ? 'opacity-50' : ''}`}
              />
              {isUploadingAvatar && (
                <div className="absolute inset-0 flex items-center justify-center">
                  <Loader2 className="animate-spin text-indigo-600" />
                </div>
              )}
            </div>
            <input
              type="file"
              ref={fileInputRef}
              accept="image/*"
              className="hidden"
              onChange={handleAvatarFileChange}
            />
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              disabled={isUploadingAvatar}
              className="text-sm text-indigo-600 font-medium hover:text-indigo-700 transition mt-1"
            >
              Change Photo
            </button>
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1.5">
              Username
            </label>
            <input
              type="text"
              name="username"
              defaultValue={userProfile?.username || ""}
              className="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:border-indigo-600 focus:ring-1 focus:ring-indigo-600 transition text-gray-900"
            />
          </div>
          <div>
            <div className="flex justify-between items-center mb-1.5">
              <label className="block text-sm font-semibold text-gray-900">
                Bio
              </label>
            </div>
            <textarea
              rows={3}
              name="bio"
              defaultValue={userProfile?.bio || ""}
              className="w-full border border-gray-300 rounded-lg px-4 py-3 focus:outline-none focus:border-indigo-600 focus:ring-1 focus:ring-indigo-600 transition resize-none text-gray-900"
            />
          </div>
          <div className="flex justify-center gap-4 mt-8 pt-4 border-t border-gray-100">
            <button
              type="button"
              onClick={() => setIsEditDialogOpen(false)}
              className="px-6 py-2 border border-indigo-600 text-indigo-600 hover:bg-indigo-50 rounded-full font-medium transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isUpdating}
              className="px-6 py-2 bg-indigo-600 text-white rounded-full font-medium hover:bg-indigo-700 transition shadow-sm disabled:opacity-70"
            >
              {isUpdating ? "Saving..." : "Save Changes"}
            </button>
          </div>
        </form>
      </Dialog>

      <FollowsModal
        userId={userProfile?.id}
        isOpen={isFollowersDialogOpen}
        onClose={() => setIsFollowersDialogOpen(false)}
        type="followers"
      />

      <FollowsModal
        userId={userProfile?.id}
        isOpen={isFollowingsDialogOpen}
        onClose={() => setIsFollowingsDialogOpen(false)}
        type="followings"
      />
    </div>
  );
}
