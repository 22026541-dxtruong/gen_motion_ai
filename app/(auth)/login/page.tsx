'use client';
import { Mail, Lock, ArrowRight } from 'lucide-react';
import Link from 'next/link';
import { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { loginAction } from '@/app/actions/auth';
import { buildGoogleAuthUrl } from '@/lib/runtime-config';

function LoginForm() {
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const router = useRouter();
  const searchParams = useSearchParams();
  const defaultEmail = searchParams.get('email') || '';

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    const formData = new FormData(e.currentTarget);
    try {
      const result = await loginAction(formData);
      if (result?.error) {
        setError(result.error);
      } else if (result?.success) {
        router.push('/explore');
      }
    } catch (err) {
      setError('An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

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
          <h1 className="text-3xl font-bold text-slate-900 mb-2">Welcome back</h1>
          <p className="text-slate-500 mb-8 text-sm">Sign in to your Neura Gen workspace.</p>

          {/* Form Card */}
          <div className="w-full bg-white rounded-xl p-8 shadow-[0_4px_40px_-12px_rgba(0,0,0,0.05)] border border-gray-100">
            {error && (
              <div className="mb-4 p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100">
                {error}
              </div>
            )}
            <form className="space-y-5" onSubmit={handleSubmit} method="POST">
              
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
                    className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-400 text-slate-900"
                    required
                  />
                </div>
              </div>

              {/* Password Input */}
              <div>
                <div className="flex items-center justify-between mb-1.5">
                  <label className="block text-sm font-semibold text-slate-900">
                    Password
                  </label>
                  <Link href="/forgot-password" className="text-xs text-indigo-600 hover:text-indigo-700 font-medium">
                    Forgot Password?
                  </Link>
                </div>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Lock className="h-4 w-4 text-gray-400" />
                  </div>
                  <input
                    type="password"
                    name="password"
                    placeholder="••••••••"
                    className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-400 text-slate-900"
                    required
                  />
                </div>
              </div>

              {/* Log In Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full bg-[#4F46E5] hover:bg-[#4338CA] text-white font-medium py-2.5 rounded-lg flex items-center justify-center gap-2 transition-colors mt-2 disabled:opacity-70 disabled:cursor-not-allowed"
              >
                {isLoading ? 'Logging In...' : <>Log In <ArrowRight className="h-4 w-4" /></>}
              </button>

              {/* Divider */}
              <div className="relative flex items-center py-2">
                <div className="flex-grow border-t border-gray-200"></div>
                <span className="flex-shrink-0 mx-4 text-slate-400 text-[11px] font-semibold tracking-wider uppercase">
                  OR CONTINUE WITH
                </span>
                <div className="flex-grow border-t border-gray-200"></div>
              </div>

              {/* Google Log In Button */}
              <a
                href={buildGoogleAuthUrl()}
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

          {/* Footer Link */}
          <p className="mt-8 text-sm text-slate-500">
            Don't have an account?{' '}
            <Link href="/register" className="text-indigo-600 hover:text-indigo-700 font-medium">
              Register
            </Link>
          </p>
          
        </div>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-[#F8F9FE]" />}>
      <LoginForm />
    </Suspense>
  );
}
