"use client";

import React, { useState } from "react";
import { CheckCircle2, Download, Maximize, Image as ImageIcon, Play, Send } from "lucide-react";
import Dialog from "../../component/Dialog";
import PublishDialog from "../../component/PublishDialog";

export default function JobItem({ job }: { job: any }) {
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);
  const [isPublishOpen, setIsPublishOpen] = useState(false);

  const isProcessing = ["PENDING", "QUEUED", "PROCESSING"].includes(job.status);

  if (isProcessing) {
    return (
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-indigo-100 relative overflow-hidden">
        <div className="absolute top-0 left-0 w-1 h-full bg-indigo-500"></div>
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-center gap-2">
            <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></div>
            <span className="text-xs font-bold text-slate-700 tracking-wide">LIVE STATUS</span>
          </div>
          <span className="bg-indigo-50 text-indigo-600 text-xs font-bold px-2.5 py-1 rounded-md">
            {job.status}
          </span>
        </div>

        <div className="flex gap-4 mb-5">
          <div className="h-[88px] w-[88px] rounded-lg overflow-hidden shrink-0 relative bg-slate-100 flex items-center justify-center">
            {job.thumbnail?.downloadUrl ? (
              <img src={job.thumbnail.downloadUrl} alt="thumb" className="w-full h-full object-cover opacity-50" />
            ) : (
              <span className="text-xs text-slate-400 font-medium">Processing</span>
            )}
          </div>
          <div className="flex-1 flex flex-col justify-center">
            <h4 className="font-semibold text-slate-900 line-clamp-1 mb-1">
              {job.prompt || "Video Generation"}
            </h4>
            <p className="text-xs text-slate-500 mb-4">ID: {job.id.substring(0, 8)}</p>
            <div className="flex items-center justify-between text-xs text-indigo-600 font-medium mb-1.5">
              <span>Generating...</span>
              <span>{job.progress || 0}%</span>
            </div>
            <div className="w-full bg-slate-100 rounded-full h-1.5">
              <div
                className="bg-indigo-500 h-1.5 rounded-full transition-all duration-500"
                style={{ width: `${job.progress || 0}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100 flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <div className="flex gap-4 items-center">
          <div className="h-12 w-12 rounded-lg bg-slate-100 shrink-0 flex items-center justify-center overflow-hidden">
            {job.thumbnail?.downloadUrl ? (
              <img src={job.thumbnail.downloadUrl} alt="thumb" className="w-full h-full object-cover" />
            ) : job.output?.downloadUrl ? (
              <video src={job.output.downloadUrl} className="w-full h-full object-cover" />
            ) : (
              <ImageIcon className="h-5 w-5 text-slate-400" />
            )}
          </div>
          <div>
            <h4 className="font-semibold text-slate-900 mb-0.5 max-w-[200px] truncate">
              {job.prompt || "Completed Video"}
            </h4>
            <div
              className={`flex items-center gap-1.5 text-xs font-medium ${job.status === "FAILED" ? "text-red-600" : "text-emerald-600"
                }`}
            >
              <CheckCircle2 className="h-3.5 w-3.5" /> {job.status}
            </div>
          </div>
        </div>
      </div>
      {job.status === "COMPLETED" && (
        <div className="flex gap-3">
          {job.output?.downloadUrl ? (
            <a
              href={job.output.downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              download
              className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5"
            >
              <Download className="h-4 w-4" /> Download
            </a>
          ) : (
            <button
              disabled
              className="flex-1 border border-slate-200 bg-slate-50 text-slate-400 py-2.5 rounded-lg text-sm font-medium flex items-center justify-center gap-1.5 cursor-not-allowed"
            >
              <Download className="h-4 w-4" /> Download
            </button>
          )}

          <button
            onClick={() => setIsPreviewOpen(true)}
            disabled={!job.output?.downloadUrl}
            className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Play className="h-4 w-4" /> Watch
          </button>

          <button
            onClick={() => setIsPublishOpen(true)}
            disabled={!job.output?.downloadUrl}
            className="flex-1 bg-indigo-50 border border-indigo-100 hover:bg-indigo-100 text-indigo-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Send className="h-4 w-4" /> Publish
          </button>
        </div>
      )}

      {isPublishOpen && (
        <PublishDialog
          isOpen={isPublishOpen}
          onClose={() => setIsPublishOpen(false)}
          assetId={job.output?.assetId}
          defaultCaption={job.prompt}
        />
      )}

      {job.output?.downloadUrl && (
        <Dialog
          isOpen={isPreviewOpen}
          onClose={() => setIsPreviewOpen(false)}
          title="Video Preview"
        >
          <div className="w-full bg-black rounded-xl overflow-hidden aspect-video flex items-center justify-center">
            <video
              controls
              autoPlay
              className="w-full h-full object-contain"
              src={job.output.downloadUrl}
            />
          </div>
        </Dialog>
      )}
    </div>
  );
}
