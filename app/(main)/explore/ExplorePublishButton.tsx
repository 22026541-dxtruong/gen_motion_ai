"use client";

import React, { useState } from "react";
import { Film } from "lucide-react";
import { useRouter } from "next/navigation";
import SelectJobDialog from "@/component/SelectJobDialog";
import PublishDialog from "@/component/PublishDialog";

type DialogState =
  | { step: "idle" }
  | { step: "select" }
  | { step: "publish"; job: any };

export default function ExplorePublishButton({
  jobs,
  isAuthenticated,
}: {
  jobs: any[];
  isAuthenticated: boolean;
}) {
  const router = useRouter();
  const [dialog, setDialog] = useState<DialogState>({ step: "idle" });

  const handleClick = () => {
    if (!isAuthenticated) {
      router.push("/login");
      return;
    }
    setDialog({ step: "select" });
  };

  return (
    <>
      <button
        onClick={handleClick}
        className="fixed bottom-10 right-10 bg-indigo-500 hover:bg-indigo-600 text-white p-4 rounded-full shadow-xl shadow-indigo-200 transition-transform hover:scale-105 z-20 flex items-center justify-center group"
      >
        <Film className="h-6 w-6" />
        <span className="absolute right-full mr-4 bg-gray-900 text-white text-sm px-3 py-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
          Post a Video
        </span>
      </button>

      {/* Step 1: Select a completed job */}
      <SelectJobDialog
        isOpen={dialog.step === "select"}
        onClose={() => setDialog({ step: "idle" })}
        jobs={jobs}
        onSelectJob={(job) => {
          // Move directly to publish step — don't go through idle (avoids unmount flash)
          setDialog({ step: "publish", job });
        }}
      />

      {/* Step 2: Write caption and publish */}
      {dialog.step === "publish" && (
        <PublishDialog
          isOpen
          onClose={() => setDialog({ step: "idle" })}
          assetId={dialog.job.output?.assetId ?? null}
          defaultCaption={dialog.job.prompt ?? ""}
        />
      )}
    </>
  );
}
