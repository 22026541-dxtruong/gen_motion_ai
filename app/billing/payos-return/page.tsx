"use client";

import Link from "next/link";
import { Suspense } from "react";
import { useSearchParams } from "next/navigation";

function resolvePaymentState(searchParams: URLSearchParams) {
  const status = searchParams.get("status")?.toLowerCase();
  const code = searchParams.get("code")?.toLowerCase();
  const cancel = searchParams.get("cancel")?.toLowerCase();

  if (cancel === "true" || status === "cancelled" || status === "canceled") {
    return {
      title: "Payment cancelled",
      description: "The payment was cancelled before completion. You can try again whenever you're ready.",
      tone: "warning",
    };
  }

  if (status === "paid" || status === "success" || code === "00") {
    return {
      title: "Payment received",
      description: "Your order was submitted successfully. Credits or subscription status should update shortly.",
      tone: "success",
    };
  }

  return {
    title: "Payment processing",
    description: "We are waiting for the final confirmation from the payment gateway. You can review the order history in Billing.",
    tone: "neutral",
  };
}

function PayosReturnContent() {
  const searchParams = useSearchParams();
  const state = resolvePaymentState(searchParams);

  const toneClasses =
    state.tone === "success"
      ? "bg-emerald-100 text-emerald-700"
      : state.tone === "warning"
        ? "bg-amber-100 text-amber-700"
        : "bg-slate-100 text-slate-700";

  return (
    <div className="min-h-screen bg-[#F8F9FE] flex items-center justify-center p-4 sm:p-8">
      <div className="relative w-full max-w-[720px] overflow-hidden rounded-[2rem] border border-slate-100 bg-white p-8 shadow-[0_24px_80px_-32px_rgba(15,23,42,0.25)] sm:p-10">
        <div className="absolute inset-x-0 top-0 h-2 bg-gradient-to-r from-[#2563EB] via-[#0EA5E9] to-[#14B8A6]" />
        <div className={`mb-6 inline-flex rounded-full px-4 py-2 text-sm font-semibold ${toneClasses}`}>
          PayOS return
        </div>
        <h1 className="text-3xl font-bold text-slate-900">{state.title}</h1>
        <p className="mt-3 text-base leading-7 text-slate-600">{state.description}</p>

        <div className="mt-8 rounded-2xl bg-slate-50 p-5 text-sm text-slate-600">
          <div>Order code: {searchParams.get("orderCode") || "N/A"}</div>
          <div className="mt-2">Status: {searchParams.get("status") || "pending"}</div>
        </div>

        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <Link
            href="/billing"
            className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800"
          >
            Back to Billing
          </Link>
          <Link
            href="/explore"
            className="inline-flex items-center justify-center rounded-xl border border-slate-200 px-5 py-3 text-sm font-semibold text-slate-700 transition hover:bg-slate-50"
          >
            Continue to Explore
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function PayosReturnPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-[#F8F9FE]" />}>
      <PayosReturnContent />
    </Suspense>
  );
}
