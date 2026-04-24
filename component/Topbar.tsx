import React from 'react';
import { Search, Bell, CreditCard } from 'lucide-react';

export default function Topbar() {
  return (
    <header className="h-16 bg-white border-b border-slate-100 flex items-center justify-between px-6 shrink-0 z-10">
      <div className="flex items-center gap-12 w-64">
        <h1 className="text-xl font-bold text-indigo-600">Neura Gen</h1>
      </div>

      <div className="flex-1 flex justify-center">
        <div className="relative w-full max-w-xl">
          <Search className="absolute left-4 top-2.5 h-4 w-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search creations..."
            className="w-full bg-[#f0f4f8] rounded-full pl-11 pr-4 py-2 text-sm outline-none focus:ring-2 focus:ring-indigo-100 transition-all placeholder:text-slate-400"
          />
        </div>
      </div>

      <div className="flex items-center gap-6 justify-end w-64">
        <button className="text-slate-400 hover:text-slate-600">
          <Bell className="h-5 w-5" />
        </button>
        <div className="flex items-center gap-2 text-indigo-600 font-medium text-sm cursor-pointer">
          <CreditCard className="h-5 w-5" />
          <span>1,240</span>
        </div>
        <button className="h-8 w-8 rounded-full overflow-hidden border border-slate-200">
          <img
            src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100"
            alt="User profile"
            className="h-full w-full object-cover"
          />
        </button>
      </div>
    </header>
  );
}