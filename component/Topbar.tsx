'use client';
import React, { useState, useRef, useEffect } from 'react';
import { Search, Bell, CreditCard, LogOut, Key, Users } from 'lucide-react';
import { logoutAction } from '@/app/actions/auth';
import Link from 'next/link';
import ChangePasswordDialog from './ChangePasswordDialog';
import SwitchAccountDialog from './SwitchAccountDialog';

export default function Topbar({ user }: { user?: any }) {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isChangePasswordOpen, setIsChangePasswordOpen] = useState(false);
  const [isSwitchAccountOpen, setIsSwitchAccountOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const [savedAccounts, setSavedAccounts] = useState<any[]>([]);

  // Load saved accounts on mount
  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem('saved_accounts') || '[]');
      setSavedAccounts(saved);
    } catch (e) {
      console.error('Failed to parse saved_accounts', e);
    }
  }, []);

  // Maintain saved_accounts in localStorage when user logs in
  useEffect(() => {
    if (user?.email && user?.username) {
      try {
        const saved = JSON.parse(localStorage.getItem('saved_accounts') || '[]');
        const existingIdx = saved.findIndex((a: any) => a.email === user.email);
        const newAccount = { email: user.email, username: user.username, avatarUrl: user.avatarUrl || null };
        
        if (existingIdx >= 0) {
          saved[existingIdx] = newAccount;
        } else {
          saved.push(newAccount);
        }
        localStorage.setItem('saved_accounts', JSON.stringify(saved));
        setSavedAccounts(saved); // Update state as well
      } catch (e) {
        console.error('Failed to parse saved_accounts', e);
      }
    }
  }, [user]);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [dropdownRef]);

  const handleLogout = async () => {
    await logoutAction();
  };

  return (
    <>
      <header className="h-16 bg-white border-b border-slate-100 flex items-center justify-between px-6 shrink-0 z-50">
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
            <span>{user?.credits?.balance || 0}</span>
          </div>
          
          {user ? (
            <div className="relative" ref={dropdownRef}>
              <button 
                onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                className="h-8 w-8 rounded-full overflow-hidden border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-100 transition-all bg-indigo-50 flex items-center justify-center text-indigo-700 font-bold"
              >
                {user.avatarUrl ? (
                  <img
                    src={user.avatarUrl}
                    alt="User profile"
                    className="h-full w-full object-cover"
                  />
                ) : (
                  <span className="text-sm">{user.username ? user.username.charAt(0).toUpperCase() : 'U'}</span>
                )}
              </button>
              
              {isDropdownOpen && (
                <div className="absolute right-0 mt-2 w-60 bg-white rounded-xl shadow-[0_10px_40px_-10px_rgba(0,0,0,0.15)] border border-slate-100 py-2 z-50">
                  <div className="px-4 py-3">
                    <p className="text-[15px] font-medium text-slate-800">{user.username}</p>
                    <p className="text-xs text-slate-500 mt-0.5 truncate">{user.email}</p>
                  </div>
                  
                  <div className="h-px bg-slate-100 my-1"></div>
                  
                  <div className="py-1">
                    <button 
                      onClick={() => {
                        setIsDropdownOpen(false);
                        setIsChangePasswordOpen(true);
                      }}
                      className="w-full flex items-center gap-3 px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 transition-colors text-left"
                    >
                      <Key className="h-[18px] w-[18px]" />
                      <span>Change Password</span>
                    </button>
                    
                    <button 
                      onClick={() => {
                        setIsDropdownOpen(false);
                        setIsSwitchAccountOpen(true);
                      }}
                      className="w-full flex items-center gap-3 px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 transition-colors text-left mt-1"
                    >
                      <Users className="h-[18px] w-[18px]" />
                      <span>Switch Account</span>
                    </button>
                  </div>
                  
                  <div className="h-px bg-slate-100 my-1"></div>
                  
                  <div className="py-1">
                    <button 
                      onClick={handleLogout}
                      className="w-full flex items-center gap-3 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors text-left font-medium"
                    >
                      <LogOut className="h-[18px] w-[18px]" />
                      <span>Logout</span>
                    </button>
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="flex items-center gap-3">
              {savedAccounts.length > 0 && (
                <button 
                  onClick={() => setIsSwitchAccountOpen(true)}
                  className="flex items-center gap-2 px-3 py-1.5 rounded-full border border-slate-200 hover:bg-slate-50 transition-colors"
                >
                  <div className="h-6 w-6 rounded-full bg-indigo-100 flex items-center justify-center text-xs font-bold text-indigo-600 overflow-hidden">
                    {savedAccounts[savedAccounts.length - 1].avatarUrl ? (
                      <img src={savedAccounts[savedAccounts.length - 1].avatarUrl} alt="Avatar" className="h-full w-full object-cover" />
                    ) : (
                      savedAccounts[savedAccounts.length - 1].username.charAt(0).toUpperCase()
                    )}
                  </div>
                  <span className="text-sm font-medium text-slate-700 whitespace-nowrap">
                    Continue as {savedAccounts[savedAccounts.length - 1].username}
                  </span>
                </button>
              )}
              <Link href="/login" className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors whitespace-nowrap">
                Log In
              </Link>
            </div>
          )}
        </div>
      </header>

      <ChangePasswordDialog 
        isOpen={isChangePasswordOpen} 
        onClose={() => setIsChangePasswordOpen(false)} 
      />

      <SwitchAccountDialog
        isOpen={isSwitchAccountOpen}
        onClose={() => setIsSwitchAccountOpen(false)}
        currentUserEmail={user?.email}
      />
    </>
  );
}