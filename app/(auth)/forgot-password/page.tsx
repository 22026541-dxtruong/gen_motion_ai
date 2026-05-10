'use client';
import { Mail, ArrowRight, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { forgotPasswordAction } from '@/app/actions/auth';

export default function ForgotPasswordPage() {
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    const formData = new FormData(e.currentTarget);
    const email = formData.get('email') as string;
    try {
      const result = await forgotPasswordAction(email);
      if (result?.error) {
        setError(result.error);
      } else if (result?.success) {
        setSuccess(true);
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
          <h1 className="text-3xl font-bold text-slate-900 mb-2">Forgot Password</h1>
          <p className="text-slate-500 mb-8 text-sm text-center">
            Enter your email address and we'll send you a link to reset your password.
          </p>

          {/* Form Card */}
          <div className="w-full bg-white rounded-xl p-8 shadow-[0_4px_40px_-12px_rgba(0,0,0,0.05)] border border-gray-100">
            {error && (
              <div className="mb-4 p-3 bg-red-50 text-red-600 text-sm rounded-lg border border-red-100">
                {error}
              </div>
            )}
            
            {success ? (
              <div className="text-center space-y-6">
                <div className="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto">
                  <Mail className="w-8 h-8" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-lg mb-2">Check your email</h3>
                  <p className="text-slate-500 text-sm">
                    We've sent a password reset link to your email address.
                  </p>
                </div>
                <Link href="/login" className="flex items-center justify-center gap-2 text-sm font-semibold text-indigo-600 hover:text-indigo-700">
                  <ArrowLeft size={16} /> Back to sign in
                </Link>
              </div>
            ) : (
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
                      className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-colors placeholder:text-gray-400 text-slate-900"
                      required
                    />
                  </div>
                </div>

                {/* Submit Button */}
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full bg-slate-900 text-white py-2.5 rounded-lg text-sm font-semibold hover:bg-slate-800 transition-all active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2 group"
                >
                  {isLoading ? 'Sending...' : 'Send reset link'}
                  {!isLoading && <ArrowRight size={16} className="group-hover:translate-x-0.5 transition-transform" />}
                </button>
              </form>
            )}
          </div>

          {!success && (
            <p className="mt-8 text-sm text-slate-600">
              Remembered your password?{' '}
              <Link href="/login" className="font-semibold text-indigo-600 hover:text-indigo-700 transition-colors">
                Sign in
              </Link>
            </p>
          )}

        </div>
      </div>
    </div>
  );
}
