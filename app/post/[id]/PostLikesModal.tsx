"use client";

import React, { useEffect, useState } from "react";
import { getPostLikesAction } from "@/app/actions/post";
import Link from "next/link";
import { X, Loader2 } from "lucide-react";

interface PostLikesModalProps {
  postId: string;
  isOpen: boolean;
  onClose: () => void;
}

type PostLike = {
  id: string;
  user: {
    id: string;
    username: string;
    avatarUrl?: string | null;
  };
};

export default function PostLikesModal({ postId, isOpen, onClose }: PostLikesModalProps) {
  const [likes, setLikes] = useState<PostLike[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen) {
      fetchLikes();
    }
  }, [isOpen, postId]);

  const fetchLikes = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await getPostLikesAction(postId);
      if (res.success && res.data && res.data.data) {
        setLikes(res.data.data);
      } else {
        setError("Failed to load likes");
      }
    } catch (error) {
      setError(error instanceof Error ? error.message : "An error occurred");
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="bg-white rounded-2xl w-full max-w-sm flex flex-col overflow-hidden shadow-2xl animate-in fade-in zoom-in duration-200">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-slate-100">
          <h2 className="font-semibold text-slate-900">Likes</h2>
          <button
            onClick={onClose}
            className="p-1 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto max-h-[60vh] p-4">
          {isLoading ? (
            <div className="flex items-center justify-center py-10">
              <Loader2 className="h-6 w-6 text-slate-400 animate-spin" />
            </div>
          ) : error ? (
            <div className="text-center text-red-500 py-6 text-sm">{error}</div>
          ) : likes.length === 0 ? (
            <div className="text-center text-slate-400 py-10 text-sm">
              No likes yet.
            </div>
          ) : (
            <div className="space-y-4">
              {likes.map((like) => (
                <div key={like.id} className="flex items-center justify-between">
                  <Link
                    href={`/user/${like.user.id}`}
                    onClick={onClose}
                    className="flex items-center gap-3 group"
                  >
                    <div className="w-10 h-10 rounded-full bg-slate-100 overflow-hidden">
                      {like.user.avatarUrl ? (
                        <img
                          src={like.user.avatarUrl}
                          alt={like.user.username}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full bg-indigo-50 text-indigo-500 flex items-center justify-center font-bold text-sm">
                          {like.user.username.charAt(0).toUpperCase()}
                        </div>
                      )}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-slate-900 group-hover:underline">
                        {like.user.username}
                      </p>
                    </div>
                  </Link>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
