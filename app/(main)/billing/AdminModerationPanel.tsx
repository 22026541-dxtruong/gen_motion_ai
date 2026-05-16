"use client";

import React, { useState } from "react";
import {
  deleteCommentAction,
  deletePostAction,
  unlikePostAction,
} from "@/app/actions/post";
import { unfollowUserAction } from "@/app/actions/user";
import { CheckCircle2, Loader2, ShieldAlert, Trash2 } from "lucide-react";

type StatusState = {
  type: "success" | "error";
  text: string;
} | null;

export default function AdminModerationPanel() {
  const [deletePostId, setDeletePostId] = useState("");
  const [deleteCommentId, setDeleteCommentId] = useState("");
  const [removeLikePostId, setRemoveLikePostId] = useState("");
  const [removeLikeUserId, setRemoveLikeUserId] = useState("");
  const [removeFollowUserId, setRemoveFollowUserId] = useState("");
  const [removeFollowFollowerId, setRemoveFollowFollowerId] = useState("");
  const [loadingAction, setLoadingAction] = useState<
    "deletePost" | "deleteComment" | "removeLike" | "removeFollow" | null
  >(null);
  const [status, setStatus] = useState<StatusState>(null);

  const showError = (message: string) => {
    setStatus({ type: "error", text: message });
  };

  const showSuccess = (message: string) => {
    setStatus({ type: "success", text: message });
  };

  const handleDeletePost = async () => {
    const postId = deletePostId.trim();
    if (!postId) {
      showError("Vui lòng nhập Post ID.");
      return;
    }

    if (!window.confirm(`Xác nhận xoá post ${postId}?`)) {
      return;
    }

    setLoadingAction("deletePost");
    setStatus(null);
    const res = await deletePostAction(postId);
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể xoá post.");
      return;
    }

    showSuccess("Đã xoá post thành công.");
  };

  const handleDeleteComment = async () => {
    const commentId = deleteCommentId.trim();
    if (!commentId) {
      showError("Vui lòng nhập Comment ID.");
      return;
    }

    if (!window.confirm(`Xác nhận xoá comment ${commentId}?`)) {
      return;
    }

    setLoadingAction("deleteComment");
    setStatus(null);
    const res = await deleteCommentAction(commentId);
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể xoá comment.");
      return;
    }

    showSuccess("Đã xoá comment thành công.");
  };

  const handleRemoveLike = async () => {
    const postId = removeLikePostId.trim();
    const userId = removeLikeUserId.trim();
    if (!postId || !userId) {
      showError("Cần nhập cả Post ID và Like Owner User ID.");
      return;
    }

    setLoadingAction("removeLike");
    setStatus(null);
    const res = await unlikePostAction(postId, userId);
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể gỡ like.");
      return;
    }

    showSuccess("Đã gỡ like của user mục tiêu.");
  };

  const handleRemoveFollow = async () => {
    const followingId = removeFollowUserId.trim();
    const followerId = removeFollowFollowerId.trim();
    if (!followingId || !followerId) {
      showError("Cần nhập cả Following User ID và Follower ID.");
      return;
    }

    setLoadingAction("removeFollow");
    setStatus(null);
    const res = await unfollowUserAction(followingId, followerId);
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể gỡ follow.");
      return;
    }

    showSuccess("Đã gỡ quan hệ follow thành công.");
  };

  return (
    <section className="mt-8 rounded-3xl border border-rose-100 bg-gradient-to-br from-rose-50 via-white to-amber-50 p-6 md:p-8">
      <div className="mb-6">
        <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-rose-100 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-rose-700">
          <ShieldAlert className="h-3.5 w-3.5" />
          Admin Moderation Console
        </p>
        <h2 className="text-2xl font-bold text-slate-900">Community Controls</h2>
        <p className="mt-2 text-sm text-slate-600">
          Công cụ moderation.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
        <div className="rounded-2xl border border-white/70 bg-white/90 p-5 shadow-sm">
          <h3 className="text-base font-semibold text-slate-900">Delete Post</h3>
          <input
            value={deletePostId}
            onChange={(event) => setDeletePostId(event.target.value)}
            placeholder="Post ID"
            className="mt-4 w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm outline-none transition focus:border-rose-400 focus:ring-2 focus:ring-rose-100"
          />
          <button
            onClick={handleDeletePost}
            disabled={loadingAction === "deletePost"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-rose-600 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-rose-500 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "deletePost" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <>
                <Trash2 className="mr-2 h-4 w-4" />
                Delete Post
              </>
            )}
          </button>
        </div>

        <div className="rounded-2xl border border-white/70 bg-white/90 p-5 shadow-sm">
          <h3 className="text-base font-semibold text-slate-900">Delete Comment</h3>
          <input
            value={deleteCommentId}
            onChange={(event) => setDeleteCommentId(event.target.value)}
            placeholder="Comment ID"
            className="mt-4 w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm outline-none transition focus:border-rose-400 focus:ring-2 focus:ring-rose-100"
          />
          <button
            onClick={handleDeleteComment}
            disabled={loadingAction === "deleteComment"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-rose-600 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-rose-500 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "deleteComment" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <>
                <Trash2 className="mr-2 h-4 w-4" />
                Delete Comment
              </>
            )}
          </button>
        </div>

        <div className="rounded-2xl border border-white/70 bg-white/90 p-5 shadow-sm">
          <h3 className="text-base font-semibold text-slate-900">
            Remove Other User Like
          </h3>
          <input
            value={removeLikePostId}
            onChange={(event) => setRemoveLikePostId(event.target.value)}
            placeholder="Post ID"
            className="mt-4 w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm outline-none transition focus:border-rose-400 focus:ring-2 focus:ring-rose-100"
          />
          <input
            value={removeLikeUserId}
            onChange={(event) => setRemoveLikeUserId(event.target.value)}
            placeholder="Like Owner User ID"
            className="mt-3 w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm outline-none transition focus:border-rose-400 focus:ring-2 focus:ring-rose-100"
          />
          <button
            onClick={handleRemoveLike}
            disabled={loadingAction === "removeLike"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "removeLike" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              "Remove Like"
            )}
          </button>
        </div>

        <div className="rounded-2xl border border-white/70 bg-white/90 p-5 shadow-sm">
          <h3 className="text-base font-semibold text-slate-900">
            Remove Other User Follow
          </h3>
          <input
            value={removeFollowUserId}
            onChange={(event) => setRemoveFollowUserId(event.target.value)}
            placeholder="Following User ID (:userId in API)"
            className="mt-4 w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm outline-none transition focus:border-rose-400 focus:ring-2 focus:ring-rose-100"
          />
          <input
            value={removeFollowFollowerId}
            onChange={(event) => setRemoveFollowFollowerId(event.target.value)}
            placeholder="Follower User ID (?followerId=)"
            className="mt-3 w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm outline-none transition focus:border-rose-400 focus:ring-2 focus:ring-rose-100"
          />
          <button
            onClick={handleRemoveFollow}
            disabled={loadingAction === "removeFollow"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "removeFollow" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              "Remove Follow"
            )}
          </button>
        </div>
      </div>

      {status && (
        <div
          className={`mt-5 flex items-center gap-2 rounded-xl border px-4 py-3 text-sm ${
            status.type === "success"
              ? "border-emerald-200 bg-emerald-50 text-emerald-700"
              : "border-rose-200 bg-rose-50 text-rose-700"
          }`}
        >
          <CheckCircle2 className="h-4 w-4" />
          {status.text}
        </div>
      )}
    </section>
  );
}
