'use client';

import React, { Suspense } from "react";
import ExploreContent from "./ExploreContent";
import { useUser, useJobs } from "@/lib/swr";
import { useSearchParams } from "next/navigation";
import { Loader2 } from "lucide-react";

function ExploreInner() {
  const searchParams = useSearchParams();
  const mode = searchParams.get("mode") || "trending";
  const topic = searchParams.get("topic") || "";
  const sort = searchParams.get("sort") || "";
  const trending = searchParams.get("trending") === "true";

  const { user } = useUser();
  const { jobs } = useJobs();

  return (
    <ExploreContent
      isAuthenticated={!!user}
      userJobs={user ? jobs : []}
      initialMode={mode}
      initialTopic={topic}
      initialSort={sort}
      initialTrending={trending}
    />
  );
}

export default function ExplorePage() {
  return (
    <Suspense fallback={
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
      </div>
    }>
      <ExploreInner />
    </Suspense>
  );
}
