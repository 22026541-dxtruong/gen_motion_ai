import React from "react";
import MainLayout from "../../component/MainLayout";

export default function BillingPage() {
  return (
    <MainLayout activePage="billing">
      <div className="max-w-5xl mx-auto py-4">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold mb-4">Choose Your Plan</h1>
          <p className="text-gray-500 max-w-2xl mx-auto">
            Elevate your creative potential with AI-powered video generation. Scale
            your production with flexible credits and premium features.
          </p>
        </div>

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
              <span className="text-[3.5rem] font-bold text-slate-900">$14.99</span>
              <span className="text-gray-500 text-lg font-medium"> /month</span>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-y-10 gap-x-8 mb-10">
            {/* Feature 1 */}
            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                </svg>
              </div>
              <div>
                <div className="font-semibold text-lg text-slate-900">1,000 Credits</div>
                <div className="text-gray-500 text-sm mt-1">Reset every month</div>
              </div>
            </div>

            {/* Feature 2 */}
            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <div>
                <div className="font-semibold text-lg text-slate-900">High-Speed Processing</div>
                <div className="text-gray-500 text-sm mt-1">Priority render queue</div>
              </div>
            </div>

            {/* Feature 3 */}
            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                </svg>
              </div>
              <div>
                <div className="font-semibold text-lg text-slate-900">Pro-only Presets</div>
                <div className="text-gray-500 text-sm mt-1">Exclusive AI styles</div>
              </div>
            </div>

            {/* Feature 4 */}
            <div className="flex gap-4">
              <div className="w-12 h-12 rounded-2xl bg-[#F0F0FF] flex items-center justify-center flex-shrink-0 text-[#635BFF]">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
                </svg>
              </div>
              <div>
                <div className="font-semibold text-lg text-slate-900">4K Upscaling</div>
                <div className="text-gray-500 text-sm mt-1">Cinematic resolution</div>
              </div>
            </div>
          </div>

          <button className="w-full bg-[#8B5CF6] hover:bg-[#7C3AED] transition-colors text-white py-4 rounded-2xl font-semibold text-lg">
            Upgrade to Pro Monthly
          </button>
        </div>

        {/* Credit Top-ups */}
        <div className="mb-12">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-end mb-6 gap-2">
            <h2 className="text-2xl font-bold text-slate-900">Credit Top-ups</h2>
            <span className="text-gray-500 text-sm font-medium">No expiration on top-up credits</span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Starter Pack */}
            <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-10">
                <div className="w-12 h-12 bg-[#F5F3FF] text-[#8B5CF6] rounded-2xl flex items-center justify-center">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                  </svg>
                </div>
                <span className="text-[1.75rem] font-bold text-slate-900">$4.99</span>
              </div>
              <h3 className="text-xl font-semibold mb-2 text-slate-900">Starter Pack</h3>
              <p className="text-gray-500 text-sm mb-8 h-10">300 Credits for quick projects</p>
              <button className="w-full py-3.5 rounded-xl border border-gray-200 font-semibold text-slate-700 hover:bg-gray-50 transition-colors">
                Buy Credits
              </button>
            </div>

            {/* Creator Pack */}
            <div className="bg-white border-2 border-[#4F46E5] rounded-[2rem] p-8 relative shadow-md">
              <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-[#4F46E5] text-white px-4 py-1 rounded-full text-xs font-bold tracking-wide">
                BEST VALUE
              </div>
              <div className="flex justify-between items-start mb-10">
                <div className="w-12 h-12 bg-[#E0E7FF] text-[#4F46E5] rounded-2xl flex items-center justify-center">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                </div>
                <span className="text-[1.75rem] font-bold text-slate-900">$12.99</span>
              </div>
              <h3 className="text-xl font-semibold mb-2 text-slate-900">Creator Pack</h3>
              <p className="text-gray-500 text-sm mb-8 h-10">1,000 Credits for active creators</p>
              <button className="w-full py-3.5 rounded-xl bg-[#4F46E5] text-white font-semibold hover:bg-[#4338CA] transition-colors">
                Buy Credits
              </button>
            </div>

            {/* Studio Pack */}
            <div className="bg-white border border-gray-100 rounded-[2rem] p-8 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-10">
                <div className="w-12 h-12 bg-[#F5F3FF] text-[#8B5CF6] rounded-2xl flex items-center justify-center">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                  </svg>
                </div>
                <span className="text-[1.75rem] font-bold text-slate-900">$29.99</span>
              </div>
              <h3 className="text-xl font-semibold mb-2 text-slate-900">Studio Pack</h3>
              <p className="text-gray-500 text-sm mb-8 h-10">3,000 Credits for power users</p>
              <button className="w-full py-3.5 rounded-xl border border-gray-200 font-semibold text-slate-700 hover:bg-gray-50 transition-colors">
                Buy Credits
              </button>
            </div>
          </div>
        </div>

        {/* Secure Payment Methods */}
        <div className="bg-[#F8FAFC] rounded-3xl p-8 text-center">
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
    </MainLayout>
  );
}