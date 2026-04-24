import React from 'react';
import { Compass, Clapperboard, User, Wallet, HelpCircle } from 'lucide-react';
import Link from 'next/link';

interface SidebarProps {
  activePage?: 'explore' | 'create' | 'profile' | 'billing';
}

export default function Sidebar({ activePage = 'explore' }: SidebarProps) {
  return (
    <aside className="w-60 bg-[#f8f9fa] border-r border-slate-100 flex flex-col justify-between overflow-y-auto">
      <nav className="p-4 space-y-2 mt-2">
        <Link
          href="/"
          className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-colors ${
            activePage === 'explore'
              ? 'text-indigo-700 bg-white shadow-sm'
              : 'text-slate-500 hover:text-slate-900 hover:bg-slate-100'
          }`}
        >
          <Compass className="h-5 w-5" />
          Explore
        </Link>
        <Link
          href="/create"
          className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-colors ${
            activePage === 'create'
              ? 'text-indigo-700 bg-white shadow-sm'
              : 'text-slate-500 hover:text-slate-900 hover:bg-slate-100'
          }`}
        >
          <Clapperboard className="h-5 w-5" />
          Create
        </Link>
        <Link
          href="/profile"
          className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-colors ${
            activePage === 'profile'
              ? 'text-indigo-700 bg-white shadow-sm'
              : 'text-slate-500 hover:text-slate-900 hover:bg-slate-100'
          }`}
        >
          <User className="h-5 w-5" />
          Profile
        </Link>
        <Link
          href="/billing"
          className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-colors ${
            activePage === 'billing'
              ? 'text-indigo-700 bg-white shadow-sm'
              : 'text-slate-500 hover:text-slate-900 hover:bg-slate-100'
          }`}
        >
          <Wallet className="h-5 w-5" />
          Billing
        </Link>
      </nav>

      <div className="p-4 mb-2">
        <Link
          href="/help"
          className="flex items-center gap-3 px-4 py-3 text-slate-500 hover:text-slate-900 hover:bg-slate-100 rounded-xl font-medium transition-colors"
        >
          <HelpCircle className="h-5 w-5" />
          Help
        </Link>
      </div>
    </aside>
  );
}