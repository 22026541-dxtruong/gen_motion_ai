'use client';

import React, { useState } from 'react';
import Dialog from './Dialog';
import { changePasswordAction } from '@/app/actions/auth';

interface ChangePasswordDialogProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ChangePasswordDialog({ isOpen, onClose }: ChangePasswordDialogProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const formAction = async (formData: FormData) => {
    setIsLoading(true);
    setError(null);
    setSuccess(false);
    
    try {
      const result = await changePasswordAction(formData);
      if (result?.error) {
        setError(result.error);
      } else if (result?.success) {
        setSuccess(true);
        setTimeout(() => {
          onClose();
          setSuccess(false);
        }, 2000);
      }
    } catch (err) {
      setError('An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Dialog isOpen={isOpen} onClose={onClose} title="Change Password">
      {success ? (
        <div className="py-8 flex flex-col items-center text-center">
          <div className="h-12 w-12 rounded-full bg-green-100 flex items-center justify-center mb-4">
            <svg className="w-6 h-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-slate-900">Password Updated</h3>
          <p className="text-sm text-slate-500 mt-1">Your password has been changed successfully.</p>
        </div>
      ) : (
        <form className="space-y-4" action={formAction}>
          {error && (
            <div className="p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100">
              {error}
            </div>
          )}
          
          <div>
            <label className="block text-sm font-semibold text-slate-900 mb-1.5">
              Old Password
            </label>
            <input
              type="password"
              name="oldPassword"
              placeholder="••••••••"
              className="w-full px-4 py-2.5 bg-[#f8f9fa] border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors text-slate-900"
              required
            />
          </div>
          
          <div>
            <label className="block text-sm font-semibold text-slate-900 mb-1.5">
              New Password
            </label>
            <input
              type="password"
              name="newPassword"
              placeholder="••••••••"
              className="w-full px-4 py-2.5 bg-[#f8f9fa] border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors text-slate-900"
              required
            />
          </div>

          <div className="pt-2">
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2.5 rounded-lg transition-colors flex items-center justify-center disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Updating...' : 'Update Password'}
            </button>
          </div>
        </form>
      )}
    </Dialog>
  );
}
