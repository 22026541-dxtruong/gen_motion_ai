'use client';

import React, { useState, useEffect } from 'react';
import Dialog from './Dialog';
import { switchAccountAction, removeSavedAccountAction } from '@/app/actions/auth';
import { Check, Plus, Trash2, Loader2 } from 'lucide-react';
import LoginDialog from './LoginDialog';

interface SwitchAccountDialogProps {
  isOpen: boolean;
  onClose: () => void;
  currentUserEmail?: string;
}

export interface SavedAccount {
  email: string;
  username: string;
  avatarUrl: string | null;
}

export default function SwitchAccountDialog({ isOpen, onClose, currentUserEmail }: SwitchAccountDialogProps) {
  const [savedAccounts, setSavedAccounts] = useState<SavedAccount[]>([]);
  const [isLoading, setIsLoading] = useState<string | null>(null);
  
  const [isLoginDialogOpen, setIsLoginDialogOpen] = useState(false);
  const [requireLoginEmail, setRequireLoginEmail] = useState('');

  useEffect(() => {
    if (isOpen) {
      const saved = JSON.parse(localStorage.getItem('saved_accounts') || '[]');
      setSavedAccounts(saved);
    }
  }, [isOpen]);

  const handleSwitch = async (email: string) => {
    if (email === currentUserEmail) {
      onClose();
      return;
    }
    
    setIsLoading(email);
    const result = await switchAccountAction(email);
    
    if (result?.requireLogin) {
      setRequireLoginEmail(email);
      setIsLoginDialogOpen(true);
    } else if (result?.success) {
      window.location.reload();
    }
    
    setIsLoading(null);
  };

  const handleRemove = async (e: React.MouseEvent, email: string) => {
    e.stopPropagation();
    
    // Remove from local storage
    const updated = savedAccounts.filter(a => a.email !== email);
    setSavedAccounts(updated);
    localStorage.setItem('saved_accounts', JSON.stringify(updated));
    
    // Remove cookies
    await removeSavedAccountAction(email);
  };

  return (
    <>
      <Dialog isOpen={isOpen && !isLoginDialogOpen} onClose={onClose} title="Switch Account">
        <div className="space-y-2 max-h-[60vh] overflow-y-auto pr-1">
          {savedAccounts.map((account) => {
            const isCurrent = account.email === currentUserEmail;
            return (
              <div 
                key={account.email}
                onClick={() => handleSwitch(account.email)}
                className={`flex items-center justify-between p-3 rounded-xl border transition-all cursor-pointer ${
                  isCurrent 
                    ? 'border-indigo-500 bg-indigo-50' 
                    : 'border-slate-200 hover:border-indigo-300 hover:bg-slate-50'
                }`}
              >
                <div className="flex items-center gap-3 overflow-hidden">
                  <div className="h-10 w-10 shrink-0 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 font-bold overflow-hidden border border-slate-200">
                    {account.avatarUrl ? (
                      <img src={account.avatarUrl} alt={account.username} className="h-full w-full object-cover" />
                    ) : (
                      account.username.charAt(0).toUpperCase()
                    )}
                  </div>
                  <div className="overflow-hidden">
                    <p className="text-sm font-semibold text-slate-900 truncate">
                      {account.username}
                    </p>
                    <p className="text-xs text-slate-500 truncate">
                      {account.email}
                    </p>
                  </div>
                </div>
                
                <div className="flex items-center gap-2 shrink-0">
                  {isLoading === account.email && (
                    <Loader2 className="h-5 w-5 text-indigo-500 animate-spin" />
                  )}
                  {isCurrent && isLoading !== account.email && (
                    <div className="h-6 w-6 rounded-full bg-indigo-500 flex items-center justify-center">
                      <Check className="h-3.5 w-3.5 text-white" />
                    </div>
                  )}
                  {!isCurrent && isLoading !== account.email && (
                    <button 
                      onClick={(e) => handleRemove(e, account.email)}
                      className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-full transition-colors opacity-0 hover:opacity-100 focus:opacity-100 group-hover:opacity-100"
                      title="Remove account"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  )}
                </div>
              </div>
            );
          })}

          {savedAccounts.length === 0 && (
            <div className="text-center py-6 text-slate-500 text-sm">
              No saved accounts found.
            </div>
          )}
        </div>

        <div className="mt-4 pt-4 border-t border-slate-100">
          <button 
            onClick={() => {
              setRequireLoginEmail('');
              setIsLoginDialogOpen(true);
            }}
            className="w-full flex items-center justify-center gap-2 py-2.5 text-sm font-medium text-slate-700 bg-slate-50 hover:bg-slate-100 border border-slate-200 rounded-lg transition-colors"
          >
            <Plus className="h-4 w-4" />
            Add an existing account
          </button>
        </div>
      </Dialog>

      <LoginDialog 
        isOpen={isLoginDialogOpen} 
        onClose={() => setIsLoginDialogOpen(false)} 
        defaultEmail={requireLoginEmail}
      />
    </>
  );
}
