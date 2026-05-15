'use client';

import React from "react";
import BillingClientView from "./BillingClientView";
import BillingAdminPanel from "./BillingAdminPanel";
import { useBillingCatalog, useUser } from "@/lib/swr";
import { Loader2 } from "lucide-react";

type NormalizedCatalog = {
  pro: { price: number; credits: number };
  topup: Array<{
    code: string;
    name: string;
    price: number;
    credits: number;
  }>;
};

type BillingCatalogPayload = {
  pro?: { price?: number; credits?: number };
  topup?: Array<{
    code?: string;
    name?: string;
    price?: number;
    credits?: number;
  }>;
  proPlan?: { amountUsd?: number; credits?: number };
  creditTopupPackages?: Array<{
    code?: string;
    label?: string;
    amountUsd?: number;
    credits?: number;
  }>;
};

function getFallbackCatalog(): NormalizedCatalog {
  return {
    pro: { price: 14.99, credits: 1000 },
    topup: [
      { code: "TOPUP_STARTER_0_99", name: "Starter", price: 0.99, credits: 50 },
      { code: "TOPUP_POPULAR_4_99", name: "Popular", price: 4.99, credits: 250 },
      { code: "TOPUP_PRO_9_99", name: "Pro", price: 9.99, credits: 500 },
      { code: "TOPUP_MAX_19_99", name: "Max", price: 19.99, credits: 1000 },
    ],
  };
}

function normalizeCatalog(raw: unknown): NormalizedCatalog {
  if (!raw || typeof raw !== "object") {
    return getFallbackCatalog();
  }

  const payload = raw as BillingCatalogPayload;

  if (payload.pro && payload.topup) {
    return {
      pro: {
        price: Number(payload.pro.price ?? 14.99),
        credits: Number(payload.pro.credits ?? 1000),
      },
      topup: payload.topup.map((item) => ({
        code: String(item.code ?? ""),
        name: String(item.name ?? item.code ?? "Top-up"),
        price: Number(item.price ?? 0),
        credits: Number(item.credits ?? 0),
      })),
    };
  }

  const proPlan = payload.proPlan ?? {};
  const topupPackages = Array.isArray(payload.creditTopupPackages)
    ? payload.creditTopupPackages
    : [];

  if (topupPackages.length === 0) {
    return getFallbackCatalog();
  }

  return {
    pro: {
      price: Number(proPlan.amountUsd ?? 14.99),
      credits: Number(proPlan.credits ?? 1000),
    },
    topup: topupPackages.map((pkg) => ({
      code: String(pkg.code ?? ""),
      name: String(pkg.label ?? pkg.code ?? "Top-up"),
      price: Number(pkg.amountUsd ?? 0),
      credits: Number(pkg.credits ?? 0),
    })),
  };
}

export default function BillingPage() {
  const { catalog: rawCatalog, isLoading } = useBillingCatalog();
  const { user, isLoading: loadingUser } = useUser();
  const catalog = normalizeCatalog(rawCatalog);
  const isAdmin = user?.role === "ADMIN";

  if (isLoading || loadingUser) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto py-4">
      {/* Header */}
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4">Choose Your Plan</h1>
        <p className="text-gray-500 max-w-2xl mx-auto">
          Elevate your creative potential with AI-powered video generation. Scale
          your production with flexible credits and premium features.
        </p>
      </div>

      {/* Dynamic Billing UI (Plans & Orders) */}
      <BillingClientView catalog={catalog} />
      {isAdmin && <BillingAdminPanel />}

      {/* Secure Payment Methods */}
      <div className="bg-[#F8FAFC] rounded-3xl p-8 text-center mt-12">
        <div className="text-sm font-semibold tracking-widest text-slate-500 mb-8 uppercase">
          SECURE PAYMENT METHODS
        </div>
        <div className="flex flex-wrap justify-center items-center gap-8 mb-8 text-slate-600 font-semibold">
          <div className="flex items-center gap-2">
            <svg className="w-6 h-6 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" /></svg>
            Bank Transfer
          </div>
          <div className="flex items-center gap-2 text-slate-600">
            <div className="w-8 h-8 bg-[#E94285] rounded-md text-white font-bold text-[10px] flex items-center justify-center">
              MoMo
            </div>
            MoMo
          </div>
          <div className="flex items-center gap-2 text-slate-600">
             <svg className="w-6 h-6 text-[#635BFF]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
            PayOS
          </div>
          <div className="flex items-center gap-2">
            <svg className="w-6 h-6 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" /></svg>
            Visa / Master
          </div>
        </div>
        <div className="flex items-center justify-center gap-2 text-sm text-slate-500 font-medium">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
          All transactions are encrypted and secured by industrial-grade SSL standards.
        </div>
      </div>
    </div>
  );
}
