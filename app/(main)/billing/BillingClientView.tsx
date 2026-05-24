"use client";

import React, { useState } from "react";
import { createOrderAction } from "@/app/actions/billing";
import { Loader2, Zap, CreditCard, ArrowUpRight } from "lucide-react";
import { useMyOrders } from "@/lib/swr";
import Dialog from "@/component/Dialog";

type PackageInfo = {
  code: string;
  name: string;
  price: number;
  credits: number;
};

type Catalog = {
  pro: { price: number; credits: number };
  topup: PackageInfo[];
};

type Order = {
  id: string;
  amountUsd: string | number;
  creditAmount?: number;
  status: string;
  type: string;
  provider?: string;
  packageCode?: string;
  paidAt?: string;
  createdAt: string;
  metadata?: any;
};

export default function BillingClientView({ catalog }: { catalog: Catalog }) {
  const [activeTab, setActiveTab] = useState<"plans" | "orders">("plans");
  const [loadingOrderId, setLoadingOrderId] = useState<string | null>(null);
  const [selectedPackage, setSelectedPackage] = useState<{ type: "CREDIT_TOPUP" | "PRO_SUBSCRIPTION", packageCode?: string } | null>(null);
  const { orders, isLoading: loadingOrders } = useMyOrders();

  const handleOpenSelector = (type: "CREDIT_TOPUP" | "PRO_SUBSCRIPTION", packageCode?: string) => {
    setSelectedPackage({ type, packageCode });
  };

  const handlePurchase = async (provider: "PAYOS" | "MOMO") => {
    if (!selectedPackage) return;
    const { type, packageCode } = selectedPackage;
    setLoadingOrderId(packageCode || type);
    try {
      const res = await createOrderAction(type, provider, packageCode);
      if (res.success && res.data) {
        // Save pending order info for payos-return page to track
        try {
          localStorage.setItem("pending_order_id", res.data.id);
        } catch {}

        // Backend returns payUrl for both MoMo and PayOS
        const url = res.data.payUrl;
        if (url) {
          window.location.href = url;
        } else {
          alert("Failed to get payment URL. Please try again.");
          setLoadingOrderId(null);
        }
      } else {
        alert(res.error || "Failed to initiate payment. Please try again.");
        setLoadingOrderId(null);
      }
    } catch (err) {
      alert("Error initiating payment.");
      setLoadingOrderId(null);
    }
  };

  const getProviderLabel = (provider?: string) => {
    switch (provider) {
      case "PAYOS": return "PayOS";
      case "MOMO": return "MoMo";
      case "BANK_TRANSFER": return "Bank Transfer";
      default: return provider || "—";
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "PAID":
        return "bg-emerald-50 text-emerald-700 border border-emerald-200";
      case "PENDING":
        return "bg-amber-50 text-amber-700 border border-amber-200";
      case "FAILED":
        return "bg-red-50 text-red-700 border border-red-200";
      case "CANCELLED":
        return "bg-slate-50 text-slate-500 border border-slate-200";
      default:
        return "bg-slate-50 text-slate-500 border border-slate-200";
    }
  };

  return (
    <div className="w-full">
      {/* Tabs */}
      <div className="flex justify-center mb-8 space-x-4">
        <button
          onClick={() => setActiveTab("plans")}
          className={`px-6 py-2 rounded-full font-medium transition-colors ${
            activeTab === "plans"
              ? "bg-[#635BFF] text-white"
              : "bg-white text-slate-600 hover:bg-gray-100"
          }`}
        >
          Plans & Credits
        </button>
        <button
          onClick={() => setActiveTab("orders")}
          className={`px-6 py-2 rounded-full font-medium transition-colors ${
            activeTab === "orders"
              ? "bg-[#635BFF] text-white"
              : "bg-white text-slate-600 hover:bg-gray-100"
          }`}
        >
          My Orders
        </button>
      </div>

      {activeTab === "plans" ? (
        <div className="animate-in fade-in duration-300">
          {/* Pro Plan Card */}
          <div className="relative bg-white rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] p-8 md:p-12 mb-16 mx-auto max-w-3xl border border-gray-100">
            <div className="absolute top-0 right-0 bg-[#635BFF] text-white px-6 py-3 rounded-bl-2xl rounded-tr-[2rem] font-medium text-sm">
              MOST POPULAR
            </div>
            
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-12">
              <div>
                <div className="text-[#635BFF] text-sm font-semibold tracking-wider mb-2 uppercase">
                  PREMIUM EXPERIENCE
                </div>
                <h2 className="text-4xl font-bold text-slate-900">Pro Monthly</h2>
              </div>
              <div className="mt-4 md:mt-0">
                <span className="text-[3.5rem] font-bold text-slate-900">${(catalog?.pro?.price || 14.99).toFixed(2)}</span>
                <span className="text-gray-500 text-lg font-medium"> /month</span>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-y-10 gap-x-8 mb-10">
              <div className="flex gap-4">
                <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>
                </div>
                <div>
                  <div className="font-semibold text-lg text-slate-900">{catalog?.pro?.credits || 1000} Credits</div>
                  <div className="text-gray-500 text-sm mt-1">Reset every month</div>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                </div>
                <div>
                  <div className="font-semibold text-lg text-slate-900">High-Speed Processing</div>
                  <div className="text-gray-500 text-sm mt-1">Priority render queue</div>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" /></svg>
                </div>
                <div>
                  <div className="font-semibold text-lg text-slate-900">Pro-only Presets</div>
                  <div className="text-gray-500 text-sm mt-1">Exclusive AI styles</div>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" /></svg>
                </div>
                <div>
                  <div className="font-semibold text-lg text-slate-900">4K Upscaling</div>
                  <div className="text-gray-500 text-sm mt-1">Cinematic resolution</div>
                </div>
              </div>
            </div>

            <button 
              onClick={() => handleOpenSelector("PRO_SUBSCRIPTION")}
              disabled={loadingOrderId === "PRO_SUBSCRIPTION"}
              className="w-full flex items-center justify-center bg-[#8B5CF6] hover:bg-[#7C3AED] transition-colors text-white py-4 rounded-2xl font-semibold text-lg disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {loadingOrderId === "PRO_SUBSCRIPTION" ? <Loader2 className="w-6 h-6 animate-spin" /> : "Upgrade to Pro Monthly"}
            </button>
          </div>

          {/* Credit Top-ups */}
          <div className="mb-12">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-end mb-6 gap-2">
              <h2 className="text-2xl font-bold text-slate-900">Credit Top-ups</h2>
              <span className="text-gray-500 text-sm font-medium">No expiration on top-up credits</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-6">
              {catalog?.topup?.map((pack, idx) => (
                <div key={pack.code} className={`bg-white rounded-[2rem] p-8 shadow-sm hover:shadow-md transition-shadow ${idx === 1 ? 'border-2 border-[#4F46E5] relative shadow-md' : 'border border-gray-100'}`}>
                  {idx === 1 && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-[#4F46E5] text-white px-4 py-1 rounded-full text-xs font-bold tracking-wide">
                      BEST VALUE
                    </div>
                  )}
                  <div className="flex justify-between items-start mb-10">
                    <div className={`w-12 h-12 rounded-2xl flex items-center justify-center ${idx === 1 ? 'bg-[#E0E7FF] text-[#4F46E5]' : 'bg-[#F5F3FF] text-[#8B5CF6]'}`}>
                      <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" /></svg>
                    </div>
                    <span className="text-[1.75rem] font-bold text-slate-900">${pack.price.toFixed(2)}</span>
                  </div>
                  <h3 className="text-xl font-semibold mb-2 text-slate-900">{pack.name}</h3>
                  <p className="text-gray-500 text-sm mb-8 h-10">{pack.credits} Credits for your creative projects</p>
                  <button 
                    onClick={() => handleOpenSelector("CREDIT_TOPUP", pack.code)}
                    disabled={loadingOrderId === pack.code}
                    className={`w-full flex items-center justify-center py-3.5 rounded-xl font-semibold transition-colors disabled:opacity-70 disabled:cursor-not-allowed ${idx === 1 ? 'bg-[#4F46E5] text-white hover:bg-[#4338CA]' : 'border border-gray-200 text-slate-700 hover:bg-gray-50'}`}
                  >
                    {loadingOrderId === pack.code ? <Loader2 className="w-5 h-5 animate-spin" /> : "Buy Credits"}
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      ) : (
        <div className="animate-in fade-in duration-300">
          <div className="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden max-w-4xl mx-auto">
            <div className="p-6 border-b border-gray-100">
              <h2 className="text-2xl font-bold text-slate-900">Order History</h2>
            </div>
            {loadingOrders ? (
              <div className="flex justify-center items-center p-12">
                <Loader2 className="w-8 h-8 animate-spin text-indigo-600" />
              </div>
            ) : orders.length === 0 ? (
              <div className="p-12 text-center text-slate-500">
                You haven't made any purchases yet.
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {orders.map((order) => (
                  <div key={order.id} className="p-6 hover:bg-gray-50/50 transition-colors">
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-3 mb-1">
                          <span className="font-semibold text-slate-900">
                            {order.type === 'PRO_SUBSCRIPTION' ? 'Pro Monthly Subscription' : 'Credit Top-up'}
                          </span>
                          <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wider ${getStatusBadge(order.status)}`}>
                            {order.status}
                          </span>
                        </div>

                        <div className="flex flex-wrap items-center gap-x-4 gap-y-1 mt-2 text-sm text-slate-500">
                          {/* Credit amount */}
                          {order.creditAmount && order.creditAmount > 0 && (
                            <span className="flex items-center gap-1">
                              <Zap size={13} className="text-amber-500" />
                              <span className="font-medium text-slate-700">{order.creditAmount} credits</span>
                            </span>
                          )}

                          {/* Provider */}
                          {order.provider && (
                            <span className="flex items-center gap-1">
                              <CreditCard size={13} />
                              {getProviderLabel(order.provider)}
                            </span>
                          )}

                          {/* Package code */}
                          {order.packageCode && (
                            <span className="font-mono text-xs bg-slate-100 px-2 py-0.5 rounded">
                              {order.packageCode}
                            </span>
                          )}
                        </div>

                        <div className="flex items-center gap-3 mt-2 text-xs text-slate-400">
                          <span>
                            {order.paidAt
                              ? `Paid ${new Date(order.paidAt).toLocaleDateString()} at ${new Date(order.paidAt).toLocaleTimeString()}`
                              : `Created ${new Date(order.createdAt).toLocaleDateString()} at ${new Date(order.createdAt).toLocaleTimeString()}`
                            }
                          </span>
                          <span className="font-mono">#{order.id.substring(0, 8)}</span>
                        </div>
                      </div>

                      <div className="text-right shrink-0">
                        <div className="font-bold text-xl text-slate-900">${Number(order.amountUsd || 0).toFixed(2)}</div>
                        {order.metadata?.amountVnd && (
                          <div className="text-xs text-slate-400 mt-0.5">
                            ≈ {Number(order.metadata.amountVnd).toLocaleString()}₫
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Payment Method Modal */}
      {selectedPackage && (
        <Dialog
          isOpen={true}
          onClose={() => {
            if (!loadingOrderId) setSelectedPackage(null);
          }}
          title="Select Payment Method"
        >
          <div className="flex flex-col gap-4 mt-2">
            <button
              onClick={() => handlePurchase("PAYOS")}
              disabled={!!loadingOrderId}
              className="w-full flex items-center justify-between p-4 border border-gray-200 rounded-xl hover:bg-indigo-50 hover:border-indigo-200 transition-colors disabled:opacity-50 text-left"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-[#635BFF]/10 text-[#635BFF] rounded-lg flex items-center justify-center">
                   <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                </div>
                <div>
                  <div className="font-semibold text-gray-900">PayOS</div>
                  <div className="text-xs text-gray-500">Bank Transfer / QR Code</div>
                </div>
              </div>
              {loadingOrderId ? <Loader2 className="w-5 h-5 animate-spin text-gray-400" /> : <ArrowUpRight className="w-5 h-5 text-gray-400" />}
            </button>

            <button
              onClick={() => handlePurchase("MOMO")}
              disabled={!!loadingOrderId}
              className="w-full flex items-center justify-between p-4 border border-gray-200 rounded-xl hover:bg-pink-50 hover:border-pink-200 transition-colors disabled:opacity-50 text-left"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-[#E94285] text-white font-bold text-xs rounded-lg flex items-center justify-center">
                  MoMo
                </div>
                <div>
                  <div className="font-semibold text-gray-900">MoMo Wallet</div>
                  <div className="text-xs text-gray-500">Momo App / QR Code</div>
                </div>
              </div>
              {loadingOrderId ? <Loader2 className="w-5 h-5 animate-spin text-gray-400" /> : <ArrowUpRight className="w-5 h-5 text-gray-400" />}
            </button>
          </div>
        </Dialog>
      )}
    </div>
  );
}
