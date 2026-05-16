'use client';

import React, { useState } from 'react';
import Dialog from './Dialog';
import { loginAction } from '@/app/actions/auth';
import { Mail, Lock, ArrowRight } from 'lucide-react';
import { buildGoogleAuthUrl } from '@/lib/runtime-config';

interface LoginDialogProps {
  isOpen: boolean;
  onClose: () => void;
  defaultEmail?: string;
}

export default function LoginDialog({ isOpen, onClose, defaultEmail = '' }: LoginDialogProps) {
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const formAction = async (formData: FormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await loginAction(formData);
      if (result?.error) {
        setError(result.error);
      } else if (result?.success) {
        // Success: Reload the page to load new account state
        window.location.reload();
      }
    } catch {
      setError('An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Dialog isOpen={isOpen} onClose={onClose} title="Log In">
      <div className="w-full">
        {error && (
          <div className="mb-4 p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100">
            {error}
          </div>
        )}
        <form className="space-y-4" action={formAction}>
          
          {/* Email Input */}
          <div>
            <label className="block text-sm font-semibold text-slate-900 mb-1.5">
              Email address
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Mail className="h-4 w-4 text-gray-400" />
              </div>
              <input
                type="email"
                name="email"
                placeholder="name@company.com"
                defaultValue={defaultEmail}
                className="w-full pl-10 pr-4 py-2.5 bg-[#f8f9fa] border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-400 text-slate-900"
                required
              />
            </div>
          </div>

          {/* Password Input */}
          <div>
            <label className="block text-sm font-semibold text-slate-900 mb-1.5">
              Password
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Lock className="h-4 w-4 text-gray-400" />
              </div>
              <input
                type="password"
                name="password"
                placeholder="••••••••"
                className="w-full pl-10 pr-4 py-2.5 bg-[#f8f9fa] border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-400 text-slate-900"
                required
              />
            </div>
          </div>

          {/* Log In Button */}
          <div className="pt-2">
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-[#4F46E5] hover:bg-[#4338CA] text-white font-medium py-2.5 rounded-lg flex items-center justify-center gap-2 transition-colors disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Logging In...' : <>Log In <ArrowRight className="h-4 w-4" /></>}
            </button>
          </div>

          <div className="relative flex items-center py-1">
            <div className="flex-grow border-t border-gray-200"></div>
            <span className="flex-shrink-0 mx-3 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">
              or
            </span>
            <div className="flex-grow border-t border-gray-200"></div>
          </div>

          <a
            href={buildGoogleAuthUrl('login')}
            className="w-full bg-white hover:bg-gray-50 text-slate-700 font-medium py-2.5 rounded-lg border border-gray-200 flex items-center justify-center gap-2.5 transition-colors"
          >
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.16v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.16C1.43 8.55 1 10.22 1 12s.43 3.45 1.16 4.93l3.68-2.84z" fill="#FBBC05"/>
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.16 7.07l3.68 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
            </svg>
            <span className="text-sm">Sign in with Google</span>
          </a>
        </form>
      </div>
    </Dialog>
  );
}
