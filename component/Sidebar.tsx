'use client';

import React from 'react';
import { Compass, Clapperboard, User, Wallet, HelpCircle, ShieldCheck } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useUser } from '@/lib/swr';

export default function Sidebar() {
  const pathname = usePathname();
  const { user } = useUser();

  const getActivePage = () => {
    if (pathname.startsWith('/create')) return 'create';
    if (pathname.startsWith('/profile')) return 'profile';
    if (pathname.startsWith('/billing')) return 'billing';
    if (pathname.startsWith('/admin')) return 'admin';
    if (pathname.startsWith('/help')) return 'help';
    return 'explore';
  };

  const activePage = getActivePage();

  return (
    <aside className="w-60 bg-[#f8f9fa] border-r border-slate-100 flex flex-col justify-between overflow-y-auto">
      <nav className="p-4 space-y-2 mt-2">
        <Link
          href="/explore"
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
        {user?.role === 'ADMIN' && (
          <Link
            href="/admin"
            className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-colors ${
              activePage === 'admin'
                ? 'text-indigo-700 bg-white shadow-sm'
                : 'text-slate-500 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <ShieldCheck className="h-5 w-5" />
            Admin
          </Link>
        )}
      </nav>

      <div className="p-4 mb-2">
        <Link
          href="/help"
          className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-colors ${
            activePage === 'help'
              ? 'text-indigo-700 bg-white shadow-sm'
              : 'text-slate-500 hover:text-slate-900 hover:bg-slate-100'
          }`}
        >
          <HelpCircle className="h-5 w-5" />
          Help
        </Link>
      </div>
    </aside>
  );
}
