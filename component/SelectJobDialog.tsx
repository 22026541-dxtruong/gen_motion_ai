"use client";

import React from "react";
import Dialog from "./Dialog";

export default function SelectJobDialog({
  isOpen,
  onClose,
  jobs,
  onSelectJob,
}: {
  isOpen: boolean;
  onClose: () => void;
  jobs: any[];
  onSelectJob: (job: any) => void;
}) {
  const completedJobs = jobs?.filter((job: any) => job.status === "COMPLETED") || [];

  const formatDuration = (ms: number) => {
    if (!ms) return "0:00";
    const totalSeconds = Math.floor(ms / 1000);
    const m = Math.floor(totalSeconds / 60);
    const s = totalSeconds % 60;
    return `${m}:${s.toString().padStart(2, "0")}`;
  };

  return (
    <Dialog isOpen={isOpen} onClose={onClose} title="Select Video to Publish">
      <div className="space-y-4">
        <p className="text-sm text-slate-500">
          Choose a generated video from your workspace to publish to the public network.
        </p>

        {completedJobs.length === 0 ? (
          <div className="py-10 text-center text-slate-500 border border-slate-100 rounded-2xl bg-slate-50">
            No completed videos found in your workspace.
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-4 max-h-[60vh] overflow-y-auto p-1">
            {completedJobs.map((job) => (
              <div
                key={job.id}
                onClick={() => {
                  // Delegate closing to the parent (ExplorePublishButton)
                  // so state can transition without a flash through "idle"
                  onSelectJob(job);
                }}
                className="group relative cursor-pointer rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow border border-slate-100"
              >
                <div className="aspect-video bg-slate-100 relative">
                  <img
                    src={
                      job.thumbnail?.downloadUrl ||
                      job.output?.downloadUrl ||
                      "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=600&auto=format&fit=crop"
                    }
                    alt={job.prompt || "Video thumbnail"}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                  />
                  <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                    <span className="bg-indigo-600 text-white px-3 py-1.5 rounded-lg text-sm font-semibold shadow-sm">
                      Select
                    </span>
                  </div>
                  <span className="absolute bottom-2 right-2 bg-black/60 backdrop-blur-md text-white text-[10px] font-semibold px-2 py-0.5 rounded-md">
                    {formatDuration(
                      job.estimatedDurationSeconds ? job.estimatedDurationSeconds * 1000 : 0
                    )}
                  </span>
                </div>
                <div className="p-3 bg-white">
                  <h4 className="text-sm font-medium text-slate-900 truncate">
                    {job.prompt || "Untitled Video"}
                  </h4>
                </div>
              </div>
            ))}
          </div>
        )}

        <div className="flex justify-end pt-2">
          <button
            onClick={onClose}
            className="px-5 py-2.5 rounded-xl text-sm font-medium text-slate-700 hover:bg-slate-100 transition-colors"
          >
            Cancel
          </button>
        </div>
      </div>
    </Dialog>
  );
}
