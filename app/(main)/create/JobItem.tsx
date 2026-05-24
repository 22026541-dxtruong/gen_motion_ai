"use client";

import React, { useState, useEffect, useRef } from "react";
import { CheckCircle2, Download, Image as ImageIcon, Play, Send, XCircle, Loader2 } from "lucide-react";
import Dialog from "@/component/Dialog";
import PublishDialog from "@/component/PublishDialog";
import { useRouter } from "next/navigation";
import { createGalleryItemAction } from "@/app/actions/gallery";
import { getJobByIdAction } from "@/app/actions/job";

const TERMINAL_STATUSES = ["COMPLETED", "FAILED", "CANCELLED"];
const PROCESSING_STATUSES = ["PENDING", "QUEUED", "PROCESSING"];

export default function JobItem({ job }: { job: any }) {
  const router = useRouter();
  const [currentJob, setCurrentJob] = useState(job);
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);
  const [isPublishOpen, setIsPublishOpen] = useState(false);
  const [latestLog, setLatestLog] = useState<string | null>(null);
  const [isAddingToGallery, setIsAddingToGallery] = useState(false);
  const eventSourceRef = useRef<EventSource | null>(null);

  const isProcessing = PROCESSING_STATUSES.includes(currentJob.status);

  // SSE real-time updates for processing jobs — auto-reconnect on disconnect
  useEffect(() => {
    if (!isProcessing) return;

    let retryCount = 0;
    let retryTimer: ReturnType<typeof setTimeout> | null = null;
    let cancelled = false;

    function connect() {
      if (cancelled) return;

      const es = new EventSource(`/api/jobs/${currentJob.id}/events`);
      eventSourceRef.current = es;

      es.addEventListener("snapshot", (e) => {
        try {
          retryCount = 0; // Reset backoff on successful message
          const data = JSON.parse(e.data);
          setCurrentJob((prev: any) => ({
            ...prev,
            status: data.status,
            progress: data.progress ?? prev.progress,
            errorMessage: data.errorMessage ?? prev.errorMessage,
            startedAt: data.startedAt ?? prev.startedAt,
            completedAt: data.completedAt ?? prev.completedAt,
            failedAt: data.failedAt ?? prev.failedAt,
          }));
          if (data.logs?.length) {
            setLatestLog(data.logs[data.logs.length - 1].message);
          }
          // If snapshot shows terminal status, close and refresh seamlessly
          if (TERMINAL_STATUSES.includes(data.status)) {
            es.close();
            getJobByIdAction(currentJob.id).then((res) => {
              if (res.success && res.data) {
                setCurrentJob(res.data);
              }
            });
          }
        } catch { /* ignore parse errors */ }
      });

      es.addEventListener("status", (e) => {
        try {
          retryCount = 0;
          const data = JSON.parse(e.data);
          setCurrentJob((prev: any) => ({
            ...prev,
            status: data.status,
            progress: data.progress ?? prev.progress,
            errorMessage: data.errorMessage ?? prev.errorMessage,
            startedAt: data.startedAt ?? prev.startedAt,
            completedAt: data.completedAt ?? prev.completedAt,
            failedAt: data.failedAt ?? prev.failedAt,
          }));

          // When terminal, close the stream and refresh the page data seamlessly
          if (TERMINAL_STATUSES.includes(data.status)) {
            es.close();
            getJobByIdAction(currentJob.id).then((res) => {
              if (res.success && res.data) {
                setCurrentJob(res.data);
              }
            });
          }
        } catch { /* ignore parse errors */ }
      });

      es.addEventListener("log", (e) => {
        try {
          retryCount = 0;
          const data = JSON.parse(e.data);
          setLatestLog(data.message);
        } catch { /* ignore */ }
      });

      es.onerror = () => {
        es.close();
        eventSourceRef.current = null;
        if (cancelled) return;

        // Exponential backoff: 1s, 2s, 4s, 8s, max 15s
        const delay = Math.min(1000 * Math.pow(2, retryCount), 15000);
        retryCount++;
        retryTimer = setTimeout(connect, delay);
      };
    }

    connect();

    return () => {
      cancelled = true;
      if (retryTimer) clearTimeout(retryTimer);
      if (eventSourceRef.current) {
        eventSourceRef.current.close();
        eventSourceRef.current = null;
      }
    };
    // Only re-run when the job ID changes or it transitions to processing
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentJob.id, isProcessing]);

  // ─── Processing State UI ─────────────────────────────────────
  if (isProcessing) {
    const statusLabel =
      currentJob.status === "PENDING" ? "Waiting in queue..." :
      currentJob.status === "QUEUED" ? "Queued for processing..." :
      "Generating...";

    return (
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-indigo-100 relative overflow-hidden">
        <div className="absolute top-0 left-0 w-1 h-full bg-indigo-500"></div>
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-center gap-2">
            <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></div>
            <span className="text-xs font-bold text-slate-700 tracking-wide">LIVE STATUS</span>
          </div>
          <span className="bg-indigo-50 text-indigo-600 text-xs font-bold px-2.5 py-1 rounded-md">
            {currentJob.status}
          </span>
        </div>

        <div className="flex gap-4 mb-5">
          <div className="h-[88px] w-[88px] rounded-lg overflow-hidden shrink-0 relative bg-slate-100 flex items-center justify-center">
            {currentJob.thumbnail?.downloadUrl ? (
              <img src={currentJob.thumbnail.downloadUrl} alt="thumb" className="w-full h-full object-cover opacity-50" />
            ) : (
              <Loader2 className="h-5 w-5 text-indigo-400 animate-spin" />
            )}
          </div>
          <div className="flex-1 flex flex-col justify-center">
            <h4 className="font-semibold text-slate-900 line-clamp-1 mb-1">
              {currentJob.prompt || "Video Generation"}
            </h4>
            <p className="text-xs text-slate-500 mb-2">ID: {currentJob.id.substring(0, 8)}</p>

            {latestLog && (
              <p className="text-xs text-slate-500 mb-2 truncate italic">{latestLog}</p>
            )}

            <div className="flex items-center justify-between text-xs text-indigo-600 font-medium mb-1.5">
              <span>{statusLabel}</span>
              <span>{currentJob.progress || 0}%</span>
            </div>
            <div className="w-full bg-slate-100 rounded-full h-1.5">
              <div
                className="bg-indigo-500 h-1.5 rounded-full transition-all duration-500"
                style={{ width: `${currentJob.progress || 0}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ─── Terminal State UI (COMPLETED / FAILED / CANCELLED) ──────
  return (
    <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100 flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <div className="flex gap-4 items-center">
          <div className="h-12 w-12 rounded-lg bg-slate-100 shrink-0 flex items-center justify-center overflow-hidden">
            {currentJob.thumbnail?.downloadUrl ? (
              <img src={currentJob.thumbnail.downloadUrl} alt="thumb" className="w-full h-full object-cover" />
            ) : currentJob.output?.downloadUrl ? (
              <video src={currentJob.output.downloadUrl} className="w-full h-full object-cover" />
            ) : (
              <ImageIcon className="h-5 w-5 text-slate-400" />
            )}
          </div>
          <div>
            <h4 className="font-semibold text-slate-900 mb-0.5 max-w-[200px] truncate">
              {currentJob.prompt || "Completed Video"}
            </h4>
            <div
              className={`flex items-center gap-1.5 text-xs font-medium ${
                currentJob.status === "FAILED" || currentJob.status === "CANCELLED"
                  ? "text-red-600"
                  : "text-emerald-600"
              }`}
            >
              {currentJob.status === "FAILED" || currentJob.status === "CANCELLED" ? (
                <XCircle className="h-3.5 w-3.5" />
              ) : (
                <CheckCircle2 className="h-3.5 w-3.5" />
              )}
              {currentJob.status}
            </div>
          </div>
        </div>
      </div>

      {currentJob.status === "FAILED" && currentJob.errorMessage && (
        <p className="text-xs text-red-500 bg-red-50 p-3 rounded-lg border border-red-100">
          {currentJob.errorMessage}
        </p>
      )}

      {currentJob.status === "COMPLETED" && (
        <div className="flex gap-3">
          {currentJob.output?.downloadUrl ? (
            <a
              href={currentJob.output.downloadUrl}
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
            disabled={!currentJob.output?.downloadUrl}
            className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Play className="h-4 w-4" /> Watch
          </button>

          <button
            onClick={() => setIsPublishOpen(true)}
            disabled={!currentJob.output?.downloadUrl}
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
          assetId={currentJob.output?.assetId}
          defaultCaption={currentJob.prompt}
          jobId={currentJob.id}
        />
      )}

      {currentJob.output?.downloadUrl && (
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
              src={currentJob.output.downloadUrl}
            />
          </div>
        </Dialog>
      )}
    </div>
  );
}
