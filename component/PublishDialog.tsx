"use client";

import React, { useState } from "react";
import Dialog from "./Dialog";
import { publishVideoAction } from "@/app/actions/post";

export default function PublishDialog({
  isOpen,
  onClose,
  assetId,
  assetVersionId,
  defaultCaption = ""
}: {
  isOpen: boolean;
  onClose: () => void;
  assetId?: string | null;
  assetVersionId?: string | null;
  defaultCaption?: string;
}) {
  const [caption, setCaption] = useState(defaultCaption);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handlePublish = async () => {
    setIsLoading(true);
    setError(null);
    
    const res = await publishVideoAction(assetId || null, assetVersionId || null, caption);
    
    if (res.success) {
      setIsLoading(false);
      onClose();
    } else {
      setError(res.error || "Failed to publish");
      setIsLoading(false);
    }
  };

  return (
    <Dialog isOpen={isOpen} onClose={onClose} title="Publish to Network">
      <div className="space-y-4">
        <p className="text-sm text-slate-500">
          Share your masterpiece with the community. It will be posted to the Explore feed and your Public Gallery.
        </p>
        
        {error && (
          <div className="bg-red-50 text-red-600 p-3 rounded-lg text-sm border border-red-100">
            {error}
          </div>
        )}

        <div>
          <label className="block text-sm font-medium text-slate-700 mb-2">Caption (Optional)</label>
          <textarea
            className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-shadow bg-slate-50"
            rows={4}
            placeholder="Write something about your video..."
            value={caption}
            onChange={(e) => setCaption(e.target.value)}
          />
        </div>

        <div className="flex gap-3 justify-end pt-2">
          <button
            onClick={onClose}
            disabled={isLoading}
            className="px-5 py-2.5 rounded-xl text-sm font-medium text-slate-700 hover:bg-slate-100 transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handlePublish}
            disabled={isLoading}
            className="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2.5 rounded-xl text-sm font-medium transition-colors disabled:opacity-50 flex items-center gap-2"
          >
            {isLoading ? "Publishing..." : "Publish Post"}
          </button>
        </div>
      </div>
    </Dialog>
  );
}
