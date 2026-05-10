"use client";

import React, { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Search, SlidersHorizontal } from "lucide-react";

export default function ExploreSearch() {
  const router = useRouter();
  const searchParams = useSearchParams();
  
  const initialTopic = searchParams?.get("topic") || "";
  const initialSort = searchParams?.get("sort") || "score";
  const initialTrending = searchParams?.get("trending") === "true";
  
  const [topic, setTopic] = useState(initialTopic);
  const [sort, setSort] = useState(initialSort);
  const [trending, setTrending] = useState(initialTrending);
  const [showFilters, setShowFilters] = useState(false);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    applyFilters(topic, sort, trending);
  };

  const applyFilters = (t: string, s: string, tr: boolean) => {
    const currentParams = new URLSearchParams(Array.from(searchParams?.entries() || []));
    
    if (t.trim()) {
      currentParams.set("topic", t.trim());
    } else {
      currentParams.delete("topic");
    }
    
    if (s && s !== 'score') {
      currentParams.set("sort", s);
    } else {
      currentParams.delete("sort");
    }
    
    if (tr) {
      currentParams.set("trending", "true");
    } else {
      currentParams.delete("trending");
    }
    
    router.push(`/explore?${currentParams.toString()}`);
  };

  const handleSortChange = (newSort: string) => {
    setSort(newSort);
    applyFilters(topic, newSort, trending);
  };
  
  const handleTrendingChange = (newTrending: boolean) => {
    setTrending(newTrending);
    applyFilters(topic, sort, newTrending);
  };

  return (
    <div className="relative">
      <form onSubmit={handleSearch} className="flex items-center bg-white border border-slate-200 rounded-full px-4 py-2 shadow-sm focus-within:ring-2 focus-within:ring-indigo-100 transition-all">
        <Search className="h-4 w-4 text-slate-400 mr-2" />
        <input
          type="text"
          placeholder="Search topics..."
          value={topic}
          onChange={(e) => setTopic(e.target.value)}
          className="bg-transparent border-none focus:ring-0 text-sm text-slate-700 placeholder:text-slate-400 outline-none w-48 sm:w-64"
        />
        <button 
          type="button" 
          onClick={() => setShowFilters(!showFilters)}
          className={`ml-2 p-1.5 rounded-full transition-colors ${showFilters || sort !== 'score' || trending ? 'bg-indigo-50 text-indigo-600' : 'text-slate-400 hover:bg-slate-100 hover:text-slate-600'}`}
        >
          <SlidersHorizontal className="h-4 w-4" />
        </button>
      </form>
      
      {showFilters && (
        <div className="absolute right-0 top-full mt-2 bg-white border border-slate-100 shadow-xl rounded-2xl p-4 w-64 z-50 animate-in fade-in slide-in-from-top-2">
          <div className="mb-4">
            <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Sort By</label>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => handleSortChange('score')}
                className={`flex-1 py-1.5 text-sm font-medium rounded-lg transition-colors ${sort === 'score' ? 'bg-indigo-50 text-indigo-700' : 'bg-slate-50 text-slate-600 hover:bg-slate-100'}`}
              >
                Top Score
              </button>
              <button
                type="button"
                onClick={() => handleSortChange('newest')}
                className={`flex-1 py-1.5 text-sm font-medium rounded-lg transition-colors ${sort === 'newest' ? 'bg-indigo-50 text-indigo-700' : 'bg-slate-50 text-slate-600 hover:bg-slate-100'}`}
              >
                Newest
              </button>
            </div>
          </div>
          
          <div>
            <label className="flex items-center justify-between cursor-pointer">
              <span className="text-sm font-medium text-slate-700">Trending Only</span>
              <div className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors ${trending ? 'bg-indigo-600' : 'bg-slate-200'}`}>
                <input 
                  type="checkbox" 
                  className="sr-only" 
                  checked={trending} 
                  onChange={(e) => handleTrendingChange(e.target.checked)} 
                />
                <span className={`inline-block h-3.5 w-3.5 transform rounded-full bg-white transition-transform ${trending ? 'translate-x-4' : 'translate-x-1'}`} />
              </div>
            </label>
          </div>
        </div>
      )}
    </div>
  );
}
