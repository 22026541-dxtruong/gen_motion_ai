"use client";

import React, { useEffect, useState } from "react";
import { getUserFollowersAction, getUserFollowingsAction } from "@/app/actions/user";
import Link from "next/link";
import { X, Loader2 } from "lucide-react";

interface FollowsModalProps {
  userId: string;
  isOpen: boolean;
  onClose: () => void;
  type: "followers" | "followings";
}

export default function FollowsModal({ userId, isOpen, onClose, type }: FollowsModalProps) {
  const [users, setUsers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen) {
      fetchUsers();
    }
  }, [isOpen, userId, type]);

  const fetchUsers = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const action = type === "followers" ? getUserFollowersAction : getUserFollowingsAction;
      const res = await action(userId);
      if (res.success && res.data && res.data.data) {
        setUsers(res.data.data);
      } else {
        setError(res.error || `Failed to load ${type}`);
      }
    } catch (err: any) {
      setError(err.message || "An error occurred");
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="bg-white rounded-2xl w-full max-w-sm flex flex-col overflow-hidden shadow-2xl animate-in fade-in zoom-in duration-200">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-slate-100">
          <h2 className="font-semibold text-slate-900 capitalize">{type}</h2>
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
            <div className="flex justify-center items-center py-8">
              <Loader2 className="animate-spin text-indigo-500" size={24} />
            </div>
          ) : error ? (
            <div className="text-center py-8 text-red-500 text-sm">{error}</div>
          ) : users.length === 0 ? (
            <div className="text-center py-8 text-slate-500 text-sm">
              No {type} found.
            </div>
          ) : (
            <div className="space-y-4">
              {users.map((item) => {
                // Determine user data depending on whether it's follower or following
                const user = type === "followers" ? item.follower : item.following;
                if (!user) return null;

                return (
                  <Link
                    key={item.id}
                    href={`/user/${user.id}`}
                    onClick={onClose}
                    className="flex items-center gap-3 hover:bg-slate-50 p-2 -mx-2 rounded-xl transition-colors"
                  >
                    <img
                      src={user.avatarUrl || `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username)}&background=e0e7ff&color=4f46e5`}
                      alt={user.username}
                      className="w-10 h-10 rounded-full object-cover bg-slate-100 flex-shrink-0"
                    />
                    <div className="flex-1 overflow-hidden">
                      <p className="text-sm font-medium text-slate-900 truncate">
                        {user.username}
                      </p>
                      {user.bio && (
                        <p className="text-xs text-slate-500 truncate">{user.bio}</p>
                      )}
                    </div>
                  </Link>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
