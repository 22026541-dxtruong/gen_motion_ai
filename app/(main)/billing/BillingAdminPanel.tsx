"use client";

import React, { useMemo, useState } from "react";
import {
  confirmPayosWebhookAction,
  markOrderPaidAction,
} from "@/app/actions/billing";
import { topupCreditsAction } from "@/app/actions/user";
import { CheckCircle2, Loader2, ShieldCheck, WalletCards } from "lucide-react";
import { useSWRConfig } from "swr";

type StatusState = {
  type: "success" | "error";
  text: string;
} | null;

export default function BillingAdminPanel() {
  const { mutate } = useSWRConfig();

  const [webhookUrl, setWebhookUrl] = useState("");
  const [orderId, setOrderId] = useState("");
  const [providerOrderId, setProviderOrderId] = useState("");
  const [topupAmount, setTopupAmount] = useState("50");
  const [topupNote, setTopupNote] = useState("");
  const [loadingAction, setLoadingAction] = useState<
    "confirmWebhook" | "markPaid" | "topup" | null
  >(null);
  const [status, setStatus] = useState<StatusState>(null);

  const helperLabel = useMemo(() => {
    return "Xử lý thủ công khi cần đối soát thanh toán.";
  }, []);

  const showError = (message: string) => {
    setStatus({ type: "error", text: message });
  };

  const showSuccess = (message: string) => {
    setStatus({ type: "success", text: message });
  };

  const handleConfirmWebhook = async () => {
    setLoadingAction("confirmWebhook");
    setStatus(null);
    const res = await confirmPayosWebhookAction(webhookUrl.trim() || undefined);
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể confirm PayOS webhook.");
      return;
    }

    showSuccess("Đã confirm PayOS webhook thành công.");
  };

  const handleMarkPaid = async () => {
    const normalizedOrderId = orderId.trim();
    if (!normalizedOrderId) {
      showError("Vui lòng nhập Order ID.");
      return;
    }

    setLoadingAction("markPaid");
    setStatus(null);
    const res = await markOrderPaidAction(
      normalizedOrderId,
      providerOrderId.trim() || undefined,
    );
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể đánh dấu đơn PAID.");
      return;
    }

    await Promise.all([
      mutate("/api/proxy/billing/orders/me"),
      mutate("/api/proxy/users/me"),
    ]);
    showSuccess("Đã đánh dấu đơn thành PAID và cập nhật lại dữ liệu.");
  };

  const handleTopup = async () => {
    const amount = Number(topupAmount);
    if (!Number.isFinite(amount) || amount < 1 || !Number.isInteger(amount)) {
      showError("Amount phải là số nguyên lớn hơn hoặc bằng 1.");
      return;
    }

    setLoadingAction("topup");
    setStatus(null);
    const res = await topupCreditsAction(amount, topupNote.trim() || undefined);
    setLoadingAction(null);

    if (!res.success) {
      showError(res.error || "Không thể cộng credit.");
      return;
    }

    await mutate("/api/proxy/users/me");
    showSuccess(`Đã cộng ${amount} credits cho tài khoản ADMIN hiện tại.`);
  };

  return (
    <section className="mt-12 rounded-3xl border border-indigo-100 dark:border-indigo-500/20 bg-gradient-to-br from-indigo-50 dark:from-indigo-500/10 via-white dark:via-slate-900 to-cyan-50 dark:to-cyan-500/10 p-6 md:p-8">
      <div className="mb-6 flex items-start justify-between gap-3">
        <div>
          <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-indigo-100 dark:bg-indigo-500/20 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-indigo-700 dark:text-indigo-400">
            <ShieldCheck className="h-3.5 w-3.5" />
            Admin Billing Console
          </p>
          <h2 className="text-2xl font-bold text-slate-900 dark:text-slate-100">
            Internal Payment Controls
          </h2>
          <p className="mt-2 text-sm text-slate-600 dark:text-slate-400">{helperLabel}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <div className="rounded-2xl border border-white/70 dark:border-slate-800 bg-white/90 dark:bg-slate-900/90 p-5 shadow-sm">
          <h3 className="text-base font-semibold text-slate-900 dark:text-slate-100">
            Confirm PayOS Webhook
          </h3>
          <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
            Để trống nếu muốn dùng giá trị webhook URL từ backend env.
          </p>
          <input
            value={webhookUrl}
            onChange={(event) => setWebhookUrl(event.target.value)}
            placeholder="https://api.your-domain.com/billing/webhooks/payos"
            className="mt-4 w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-transparent dark:bg-slate-800 px-3 py-2.5 text-sm outline-none transition focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100 dark:focus:ring-indigo-500/20 dark:text-slate-100"
          />
          <button
            onClick={handleConfirmWebhook}
            disabled={loadingAction === "confirmWebhook"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-slate-900 dark:bg-slate-100 px-4 py-2.5 text-sm font-semibold text-white dark:text-slate-900 transition hover:bg-slate-800 dark:hover:bg-white disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "confirmWebhook" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              "Confirm Webhook"
            )}
          </button>
        </div>

        <div className="rounded-2xl border border-white/70 dark:border-slate-800 bg-white/90 dark:bg-slate-900/90 p-5 shadow-sm">
          <h3 className="text-base font-semibold text-slate-900 dark:text-slate-100">
            Mark Order As Paid
          </h3>
          <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
            Dùng khi cần xử lý fallback đơn pending sau khi đã xác nhận tiền vào.
          </p>
          <input
            value={orderId}
            onChange={(event) => setOrderId(event.target.value)}
            placeholder="Order ID"
            className="mt-4 w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-transparent dark:bg-slate-800 px-3 py-2.5 text-sm outline-none transition focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100 dark:focus:ring-indigo-500/20 dark:text-slate-100"
          />
          <input
            value={providerOrderId}
            onChange={(event) => setProviderOrderId(event.target.value)}
            placeholder="Provider Order ID (optional)"
            className="mt-3 w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-transparent dark:bg-slate-800 px-3 py-2.5 text-sm outline-none transition focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100 dark:focus:ring-indigo-500/20 dark:text-slate-100"
          />
          <button
            onClick={handleMarkPaid}
            disabled={loadingAction === "markPaid"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-indigo-600 dark:bg-indigo-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-indigo-500 dark:hover:bg-indigo-400 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "markPaid" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              "Set Order Paid"
            )}
          </button>
        </div>

        <div className="rounded-2xl border border-white/70 dark:border-slate-800 bg-white/90 dark:bg-slate-900/90 p-5 shadow-sm">
          <div className="flex items-center gap-2">
            <WalletCards className="h-4 w-4 text-indigo-500 dark:text-indigo-400" />
            <h3 className="text-base font-semibold text-slate-900 dark:text-slate-100">
              Manual Credit Top-up
            </h3>
          </div>
          <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
            Endpoint hiện tại cộng credit cho chính tài khoản ADMIN đang đăng nhập.
          </p>
          <input
            value={topupAmount}
            onChange={(event) => setTopupAmount(event.target.value)}
            placeholder="Amount"
            inputMode="numeric"
            className="mt-4 w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-transparent dark:bg-slate-800 px-3 py-2.5 text-sm outline-none transition focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100 dark:focus:ring-indigo-500/20 dark:text-slate-100"
          />
          <input
            value={topupNote}
            onChange={(event) => setTopupNote(event.target.value)}
            placeholder="Note (optional)"
            className="mt-3 w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-transparent dark:bg-slate-800 px-3 py-2.5 text-sm outline-none transition focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100 dark:focus:ring-indigo-500/20 dark:text-slate-100"
          />
          <button
            onClick={handleTopup}
            disabled={loadingAction === "topup"}
            className="mt-4 inline-flex w-full items-center justify-center rounded-xl bg-emerald-600 dark:bg-emerald-500 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-emerald-500 dark:hover:bg-emerald-400 disabled:cursor-not-allowed disabled:opacity-70"
          >
            {loadingAction === "topup" ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              "Add Credits"
            )}
          </button>
        </div>
      </div>

      {status && (
        <div
          className={`mt-5 flex items-center gap-2 rounded-xl border px-4 py-3 text-sm ${
            status.type === "success"
              ? "border-emerald-200 dark:border-emerald-500/30 bg-emerald-50 dark:bg-emerald-500/10 text-emerald-700 dark:text-emerald-400"
              : "border-rose-200 dark:border-rose-500/30 bg-rose-50 dark:bg-rose-500/10 text-rose-700 dark:text-rose-400"
          }`}
        >
          <CheckCircle2 className="h-4 w-4" />
          {status.text}
        </div>
      )}
    </section>
  );
}
