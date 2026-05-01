"use client";

import React, { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Search } from "lucide-react";

export default function ExploreSearch() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialTopic = searchParams?.get("topic") || "";
  const [topic, setTopic] = useState(initialTopic);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    const currentParams = new URLSearchParams(Array.from(searchParams?.entries() || []));
    if (topic.trim()) {
      currentParams.set("topic", topic.trim());
    } else {
      currentParams.delete("topic");
    }
    router.push(`/explore?${currentParams.toString()}`);
  };

  return (
    <form onSubmit={handleSearch} className="flex items-center bg-white border border-slate-200 rounded-full px-4 py-2 shadow-sm focus-within:ring-2 focus-within:ring-indigo-100 transition-all">
      <Search className="h-4 w-4 text-slate-400 mr-2" />
      <input
        type="text"
        placeholder="Search topics..."
        value={topic}
        onChange={(e) => setTopic(e.target.value)}
        className="bg-transparent border-none focus:ring-0 text-sm text-slate-700 placeholder:text-slate-400 outline-none w-48 sm:w-64"
      />
    </form>
  );
}
