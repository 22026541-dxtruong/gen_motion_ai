"use client";

import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { googleExchangeCodeAction } from "@/app/actions/auth";
import { Loader2 } from "lucide-react";
import { buildGoogleAuthUrl } from "@/lib/runtime-config";

function GoogleCallbackContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const code = searchParams.get("code");
  const [error, setError] = useState<string | null>(null);
  const intent = searchParams.get("intent") === "register" ? "register" : "login";
  const fallbackRoute = intent === "register" ? "/register" : "/login";
  const intentLabel = intent === "register" ? "sign up" : "login";
  const resolvedError = error ?? (!code ? "Invalid Google OAuth code" : null);
  const shouldSuggestRegister =
    intent === "login" &&
    typeof resolvedError === "string" &&
    resolvedError.toLowerCase().includes("not registered");

  useEffect(() => {
    if (!code) {
      setTimeout(() => router.push(fallbackRoute), 3000);
      return;
    }

    const exchangeCode = async () => {
      const res = await googleExchangeCodeAction(code);
      if (res.success) {
        window.location.replace("/explore");
      } else {
        const errorMessage = res.error || "Failed to authenticate with Google";
        setError(errorMessage);

        const requiresRegister =
          intent === "login" && errorMessage.toLowerCase().includes("not registered");
        if (requiresRegister) {
          return;
        }

        setTimeout(() => router.push(fallbackRoute), 3000);
      }
    };

    exchangeCode();
  }, [code, router, fallbackRoute, intent]);

  return (
    <div className="min-h-screen bg-[#F8F9FE] flex flex-col items-center justify-center p-4">
      {resolvedError ? (
        <div className="bg-white p-8 rounded-2xl shadow-sm text-center max-w-sm">
          <div className="w-12 h-12 bg-red-100 text-red-600 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Authentication Failed</h2>
          <p className="text-slate-500 mb-6">{resolvedError}</p>
          {shouldSuggestRegister && (
            <div className="mb-4 p-3 bg-amber-50 text-amber-700 text-sm rounded-lg border border-amber-200 text-left">
              Chưa có tài khoản. Vui lòng đăng ký bằng Google trước.
            </div>
          )}
          {shouldSuggestRegister && (
            <a
              href={buildGoogleAuthUrl("register")}
              className="inline-flex items-center justify-center mb-3 w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2.5 rounded-lg transition-colors"
            >
              Đăng ký với Google
            </a>
          )}
          <p className="text-sm text-slate-400">Redirecting to {intentLabel}...</p>
        </div>
      ) : (
        <div className="bg-white p-8 rounded-2xl shadow-sm text-center max-w-sm">
          <Loader2 className="w-10 h-10 animate-spin text-indigo-600 mx-auto mb-4" />
          <h2 className="text-xl font-bold text-slate-900 mb-2">Authenticating...</h2>
          <p className="text-slate-500">Please wait while we complete your {intentLabel}.</p>
        </div>
      )}
    </div>
  );
}

export default function GoogleCallbackPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-[#F8F9FE]" />}>
      <GoogleCallbackContent />
    </Suspense>
  );
}
