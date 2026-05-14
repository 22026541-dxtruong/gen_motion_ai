"use client";

import Link from "next/link";
import { Suspense, useEffect, useState, useRef, useCallback } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { getMyOrdersAction, syncMyOrderAction } from "@/app/actions/billing";
import { Loader2, CheckCircle2, XCircle, Clock, Zap } from "lucide-react";
import { useSWRConfig } from "swr";

type VerifiedOrder = {
  id: string;
  status: string;
  creditAmount?: number;
  type: string;
  packageCode?: string;
  paidAt?: string;
};

function PayosReturnContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const { mutate } = useSWRConfig();
  const [verifiedOrder, setVerifiedOrder] = useState<VerifiedOrder | null>(null);
  const [isPolling, setIsPolling] = useState(false);
  const pollRef = useRef<NodeJS.Timeout | null>(null);
  const attemptRef = useRef(0);

  const orderCode = searchParams.get("orderCode");
  const urlStatus = searchParams.get("status")?.toLowerCase();
  const cancel = searchParams.get("cancel")?.toLowerCase();
  const code = searchParams.get("code");

  const isCancelled = cancel === "true" || urlStatus === "cancelled" || urlStatus === "canceled";
  const urlSaysSuccess = urlStatus === "paid" || urlStatus === "success" || code === "00";

  const stopPolling = useCallback(() => {
    setIsPolling(false);
    if (pollRef.current) {
      clearInterval(pollRef.current);
      pollRef.current = null;
    }
  }, []);

  const refreshUserBillingState = useCallback(async () => {
    await Promise.all([
      mutate("/api/proxy/users/me"),
      mutate("/api/proxy/billing/orders/me"),
    ]);
  }, [mutate]);

  // Background poll to detect when backend webhook confirms payment → update Topbar
  useEffect(() => {
    if (isCancelled) return;

    const pendingOrderId = (() => {
      try { return localStorage.getItem("pending_order_id"); } catch { return null; }
    })();

    // Fetch order info once for display
    const fetchOrder = async () => {
      try {
        if (pendingOrderId) {
          await syncMyOrderAction(pendingOrderId);
        }

        const res = await getMyOrdersAction();
        if (res.success && Array.isArray(res.data)) {
          let found: any = null;
          if (pendingOrderId) {
            found = res.data.find((o: any) => o.id === pendingOrderId);
          }
          if (!found && orderCode) {
            found = res.data.find((o: any) =>
              o.metadata?.payosOrderCode === Number(orderCode)
            );
          }
          if (found) {
            setVerifiedOrder({
              id: found.id,
              status: found.status,
              creditAmount: found.creditAmount,
              type: found.type,
              packageCode: found.packageCode,
              paidAt: found.paidAt,
            });

            if (found.status === "PAID") {
              stopPolling();
              try { localStorage.removeItem("pending_order_id"); } catch {}
              await refreshUserBillingState();
              setTimeout(() => router.refresh(), 100);
              return true; // confirmed
            }
          }
        }
      } catch {}
      return false;
    };

    // Initial fetch
    fetchOrder().then((confirmed) => {
      if (confirmed) return;

      // If URL says success but backend hasn't caught up yet,
      // poll in background so Topbar updates when webhook arrives
      if (urlSaysSuccess) {
        setIsPolling(true);
        pollRef.current = setInterval(async () => {
          attemptRef.current += 1;
          const done = await fetchOrder();
          if (done || attemptRef.current >= 10) {
            stopPolling();
            try { localStorage.removeItem("pending_order_id"); } catch {}
          }
        }, 5000);
      } else {
        try { localStorage.removeItem("pending_order_id"); } catch {}
      }
    });

    return () => {
      if (pollRef.current) clearInterval(pollRef.current);
    };
  }, [isCancelled, orderCode, refreshUserBillingState, router, stopPolling, urlSaysSuccess]);

  // Display state — trust URL params for immediate feedback
  const getDisplayState = () => {
    if (isCancelled) {
      return {
        icon: <XCircle className="h-12 w-12 text-amber-500" />,
        title: "Payment Cancelled",
        description: "The payment was cancelled before completion. You can try again whenever you're ready.",
        tone: "warning" as const,
      };
    }

    // Backend confirmed
    if (verifiedOrder?.status === "PAID") {
      return {
        icon: <CheckCircle2 className="h-12 w-12 text-emerald-500" />,
        title: "Payment Successful!",
        description: verifiedOrder.creditAmount
          ? `${verifiedOrder.creditAmount} credits have been added to your account.`
          : "Your subscription has been activated successfully.",
        tone: "success" as const,
      };
    }

    if (verifiedOrder?.status === "FAILED") {
      return {
        icon: <XCircle className="h-12 w-12 text-red-500" />,
        title: "Payment Failed",
        description: "The payment could not be processed. Please try again or contact support.",
        tone: "error" as const,
      };
    }

    // URL says success → trust PayOS redirect, show success immediately
    if (urlSaysSuccess) {
      return {
        icon: <CheckCircle2 className="h-12 w-12 text-emerald-500" />,
        title: "Payment Received!",
        description: "Your payment was received by the gateway. Credits will be added to your account shortly.",
        tone: "success" as const,
      };
    }

    // Unknown
    return {
      icon: <Clock className="h-12 w-12 text-slate-400" />,
      title: "Payment Processing",
      description: "We're waiting for confirmation from the payment gateway. Check your order history for updates.",
      tone: "pending" as const,
    };
  };

  const state = getDisplayState();

  const badgeClasses = {
    success: "bg-emerald-100 text-emerald-700",
    warning: "bg-amber-100 text-amber-700",
    error: "bg-red-100 text-red-700",
    pending: "bg-blue-100 text-blue-700",
  };

  const creditAmount = verifiedOrder?.creditAmount;

  return (
    <div className="flex items-center justify-center py-12 px-4">
      <div className="relative w-full max-w-[640px] overflow-hidden rounded-[2rem] border bg-white shadow-lg">
        <div className={`h-1.5 ${
          state.tone === "success" ? "bg-gradient-to-r from-emerald-400 to-teal-400" :
          state.tone === "warning" ? "bg-gradient-to-r from-amber-400 to-orange-400" :
          state.tone === "error" ? "bg-gradient-to-r from-red-400 to-rose-400" :
          "bg-gradient-to-r from-blue-400 to-indigo-400"
        }`} />

        <div className="p-8 sm:p-10">
          <div className="flex items-center gap-4 mb-6">
            {state.icon}
            <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${badgeClasses[state.tone]}`}>
              {state.tone === "success"
                ? (verifiedOrder?.status === "PAID" ? "Confirmed" : "Received")
                : state.tone === "warning" ? "Cancelled"
                : state.tone === "error" ? "Failed"
                : "Processing"}
            </span>
          </div>

          <h1 className="text-2xl font-bold text-slate-900 mb-2">{state.title}</h1>
          <p className="text-base leading-7 text-slate-600">{state.description}</p>

          {/* Credit earned badge */}
          {state.tone === "success" && creditAmount && creditAmount > 0 && (
            <div className="mt-6 flex items-center gap-3 bg-emerald-50 border border-emerald-200 rounded-2xl p-4">
              <div className="w-10 h-10 bg-emerald-100 rounded-xl flex items-center justify-center">
                <Zap className="h-5 w-5 text-emerald-600 fill-current" />
              </div>
              <div>
                <div className="text-lg font-bold text-emerald-800">+{creditAmount} Credits</div>
                <div className="text-xs text-emerald-600">
                  {verifiedOrder?.status === "PAID" ? "Added to your account" : "Will be added shortly"}
                </div>
              </div>
            </div>
          )}

          {/* Order info */}
          {(orderCode || verifiedOrder?.id) && (
            <div className="mt-6 rounded-xl bg-slate-50 p-4 text-sm text-slate-600 space-y-1">
              {orderCode && <div>Order code: <span className="font-mono font-medium">{orderCode}</span></div>}
              {verifiedOrder?.id && <div>Order ID: <span className="font-mono font-medium">{verifiedOrder.id.substring(0, 8)}</span></div>}
              <div>Status: <span className="font-semibold">
                {verifiedOrder?.status === "PAID" ? "PAID ✓" : urlSaysSuccess ? "PAID (gateway)" : verifiedOrder?.status || (isCancelled ? "CANCELLED" : "PENDING")}
              </span></div>
              {verifiedOrder?.paidAt && <div>Paid at: {new Date(verifiedOrder.paidAt).toLocaleString()}</div>}
            </div>
          )}

          {/* Background sync indicator */}
          {isPolling && (
            <div className="mt-4 flex items-center gap-2 text-xs text-slate-400">
              <Loader2 className="h-3 w-3 animate-spin" />
              Syncing with server...
            </div>
          )}

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
    </div>
  );
}

export default function PayosReturnPage() {
  return (
    <Suspense fallback={<div className="flex items-center justify-center py-20"><Loader2 className="h-8 w-8 animate-spin text-indigo-500" /></div>}>
      <PayosReturnContent />
    </Suspense>
  );
}
