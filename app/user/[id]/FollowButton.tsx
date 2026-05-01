"use client";

import React, { useState } from "react";
import { followUserAction, unfollowUserAction } from "@/app/actions/user";
import { useRouter } from "next/navigation";

export default function FollowButton({
  userId,
  initialIsFollowing = false,
  isAuthenticated = false,
}: {
  userId: string;
  initialIsFollowing?: boolean;
  isAuthenticated?: boolean;
}) {
  const [isFollowing, setIsFollowing] = useState(initialIsFollowing);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const handleFollow = async () => {
    if (!isAuthenticated) {
      router.push("/login");
      return;
    }

    setIsLoading(true);
    // Optimistic UI update
    setIsFollowing(!isFollowing);

    let res;
    if (isFollowing) {
      res = await unfollowUserAction(userId);
    } else {
      res = await followUserAction(userId);
    }
    
    if (!res.success) {
      // Revert if failed
      setIsFollowing(isFollowing);
      console.error(res.error);
    }
    
    setIsLoading(false);
  };

  return (
    <button
      onClick={handleFollow}
      disabled={isLoading}
      className={`px-8 py-2.5 rounded-full border font-medium transition-colors shadow-sm disabled:opacity-70 ${
        isFollowing
          ? "border-slate-200 bg-slate-50 text-slate-700 hover:bg-slate-100"
          : "border-indigo-600 bg-indigo-600 text-white hover:bg-indigo-700"
      }`}
    >
      {isFollowing ? "Following" : "Follow"}
    </button>
  );
}
