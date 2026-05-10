"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { googleExchangeCodeAction } from "@/app/actions/auth";
import { Loader2 } from "lucide-react";

export default function GoogleCallbackPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const code = searchParams.get("code");
    
    if (!code) {
      setError("Invalid Google OAuth code");
      setTimeout(() => router.push("/login"), 3000);
      return;
    }

    const exchangeCode = async () => {
      const res = await googleExchangeCodeAction(code);
      if (res.success) {
        router.push("/explore");
      } else {
        setError(res.error || "Failed to authenticate with Google");
        setTimeout(() => router.push("/login"), 3000);
      }
    };

    exchangeCode();
  }, [searchParams, router]);

  return (
    <div className="min-h-screen bg-[#F8F9FE] flex flex-col items-center justify-center p-4">
      {error ? (
        <div className="bg-white p-8 rounded-2xl shadow-sm text-center max-w-sm">
          <div className="w-12 h-12 bg-red-100 text-red-600 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Authentication Failed</h2>
          <p className="text-slate-500 mb-6">{error}</p>
          <p className="text-sm text-slate-400">Redirecting to login...</p>
        </div>
      ) : (
        <div className="bg-white p-8 rounded-2xl shadow-sm text-center max-w-sm">
          <Loader2 className="w-10 h-10 animate-spin text-indigo-600 mx-auto mb-4" />
          <h2 className="text-xl font-bold text-slate-900 mb-2">Authenticating...</h2>
          <p className="text-slate-500">Please wait while we complete your login.</p>
        </div>
      )}
    </div>
  );
}
