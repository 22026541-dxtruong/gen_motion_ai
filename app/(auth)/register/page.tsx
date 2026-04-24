'use client';
import React from 'react';
import { Mail, Lock, ArrowRight } from 'lucide-react';
import Link from 'next/link';

export default function RegisterPage() {
  return (
    <div className="min-h-screen bg-[#F8F9FE] flex items-center justify-center p-4 sm:p-8">
      {/* Main Container */}
      <div className="relative w-full max-w-[1000px] bg-[#F8F9FE] min-h-[700px] rounded-2xl flex flex-col items-center justify-center overflow-hidden shadow-2xl">
        
        {/* Background Ambient Glows */}
        <div className="absolute top-[-15%] left-[-10%] w-[500px] h-[500px] rounded-full bg-indigo-200/40 blur-[100px] pointer-events-none" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[600px] h-[600px] rounded-full bg-purple-200/40 blur-[120px] pointer-events-none" />
        
        {/* Content Wrapper */}
        <div className="z-10 w-full max-w-[420px] flex flex-col items-center">
          
          {/* Header */}
          <h1 className="text-[32px] font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-purple-600 mb-2">
            Neura Gen
          </h1>
          <p className="text-slate-500 mb-8 text-sm text-center">
            Create your account to start generating.
          </p>

          {/* Form Card */}
          <div className="w-full bg-white rounded-xl p-8 shadow-[0_4px_40px_-12px_rgba(0,0,0,0.05)] border border-gray-100">
            <form className="w-full space-y-5" onSubmit={(e) => e.preventDefault()}>
            
            {/* Email Input */}
            <div>
              <label className="block text-sm font-semibold text-slate-900 mb-1.5">
                Email
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <Mail className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="email"
                  placeholder="you@example.com"
                  className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-300 text-slate-900"
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
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <Lock className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="password"
                  placeholder="••••••••"
                  className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-300 text-slate-900"
                  required
                />
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              className="w-full bg-gradient-to-r from-[#5946D2] to-[#8C3FE8] hover:from-[#4b3abc] hover:to-[#7635c4] text-white font-medium py-3 rounded-lg flex items-center justify-center gap-2 transition-all mt-4 shadow-md shadow-purple-500/20"
            >
              Create Account <ArrowRight className="h-4 w-4" />
            </button>

            {/* Divider */}
            <div className="relative flex items-center py-3">
              <div className="flex-grow border-t border-gray-200"></div>
              <span className="flex-shrink-0 mx-4 text-slate-400 text-[13px] font-medium">or</span>
              <div className="flex-grow border-t border-gray-200"></div>
            </div>

            {/* Google Sign Up Button */}
            <button
              type="button"
              className="w-full bg-white hover:bg-gray-50 text-slate-800 font-semibold py-2.5 rounded-lg border border-gray-200 flex items-center justify-center gap-2.5 transition-colors shadow-sm"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="12" cy="12" r="11" fill="#111111"/>
                <path d="M12 10.35V13.82H15.75C15.54 15.15 14.28 16.5 12 16.5C9.64 16.5 7.73 14.54 7.73 12C7.73 9.46 9.64 7.5 12 7.5C13.06 7.5 13.92 7.91 14.43 8.39L16.48 6.34C15.31 5.25 13.8 4.5 12 4.5C7.86 4.5 4.5 7.86 4.5 12C4.5 16.14 7.86 19.5 12 19.5C16.33 19.5 19.23 16.45 19.23 12.18C19.23 11.51 19.16 10.9 19.04 10.35H12Z" fill="white"/>
              </svg>
              <span className="text-[14px]">Sign up with Google</span>
            </button>
            </form>
          </div>

          {/* Footer Link */}
          <p className="mt-8 text-sm text-slate-500">
            Already have an account?{' '}
            <Link href="/login" className="text-indigo-600 hover:text-indigo-700 font-medium">
              Log In
            </Link>
          </p>
          
        </div>
      </div>
    </div>
  );
}