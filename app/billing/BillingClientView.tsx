"use client";

import React, { useState, useEffect } from "react";
import { createOrderAction, getMyOrdersAction } from "../actions/billing";
import { Loader2 } from "lucide-react";

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
  amountVnd?: number;
  status: string;
  type: string;
  createdAt: string;
};

export default function BillingClientView({ catalog }: { catalog: Catalog }) {
  const [activeTab, setActiveTab] = useState<"plans" | "orders">("plans");
  const [loadingOrderId, setLoadingOrderId] = useState<string | null>(null);
  const [orders, setOrders] = useState<Order[]>([]);
  const [loadingOrders, setLoadingOrders] = useState(false);

  useEffect(() => {
    if (activeTab === "orders") {
      fetchOrders();
    }
  }, [activeTab]);

  const fetchOrders = async () => {
    setLoadingOrders(true);
    const res = await getMyOrdersAction();
    if (res.success && res.data) {
      setOrders(res.data);
    }
    setLoadingOrders(false);
  };

  const handlePurchase = async (type: "CREDIT_TOPUP" | "PRO_SUBSCRIPTION", packageCode?: string) => {
    setLoadingOrderId(packageCode || type);
    try {
      const res = await createOrderAction(type, "PAYOS", packageCode);
      const url = res.data?.payUrl || res.data?.checkoutUrl;
      if (res.success && url) {
        window.location.href = url;
      } else {
        alert("Failed to initiate payment. Please try again.");
      }
    } catch (err) {
      alert("Error initiating payment.");
    } finally {
      setLoadingOrderId(null);
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
              onClick={() => handlePurchase("PRO_SUBSCRIPTION")}
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

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
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
                    onClick={() => handlePurchase("CREDIT_TOPUP", pack.code)}
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
                  <div key={order.id} className="p-6 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 hover:bg-gray-50 transition-colors">
                    <div>
                      <div className="font-semibold text-slate-900">
                        {order.type === 'PRO_SUBSCRIPTION' ? 'Pro Monthly Subscription' : 'Credit Top-up'}
                      </div>
                      <div className="text-sm text-slate-500 mt-1">
                        {new Date(order.createdAt).toLocaleDateString()} at {new Date(order.createdAt).toLocaleTimeString()}
                      </div>
                      <div className="text-xs text-slate-400 font-mono mt-1 mt-1">#{order.id}</div>
                    </div>
                    <div className="flex flex-col items-end">
                      <div className="font-bold text-lg text-slate-900">${Number(order.amountUsd || 0).toFixed(2)}</div>
                      <div className={`text-xs font-semibold px-2 py-1 rounded-full mt-2 uppercase ${order.status === 'PAID' ? 'bg-green-100 text-green-700' : order.status === 'PENDING' ? 'bg-amber-100 text-amber-700' : order.status === 'CANCELLED' ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-700'}`}>
                        {order.status}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
