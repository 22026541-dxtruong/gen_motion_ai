"use client";

import React from "react";
import Link from "next/link";
import {
  HelpCircle,
  LifeBuoy,
  Mail,
  MessageCircle,
  ShieldCheck,
  Wallet,
} from "lucide-react";
import { useUser } from "@/lib/swr";

export default function HelpPage() {
  const { user } = useUser();
  const isAdmin = user?.role === "ADMIN";

  return (
    <div className="mx-auto max-w-4xl py-4 transition-colors">
      <div className="mb-8 rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-6 shadow-sm md:p-8">
        <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-slate-100 dark:bg-slate-800 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-slate-600 dark:text-slate-400">
          <HelpCircle className="h-3.5 w-3.5" />
          Help Center
        </p>
        <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">Need a hand?</h1>
        <p className="mt-2 text-sm text-slate-600 dark:text-slate-400">
          Quick guide for billing, credits, and common troubleshooting.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
        <div className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-5 shadow-sm">
          <div className="mb-3 inline-flex h-9 w-9 items-center justify-center rounded-xl bg-indigo-100 dark:bg-indigo-500/20 text-indigo-600 dark:text-indigo-400">
            <Wallet className="h-4 w-4" />
          </div>
          <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">Billing Basics</h2>
          <ul className="mt-3 space-y-2 text-sm text-slate-600 dark:text-slate-400">
            <li>1. Purchase credit packages in the Billing tab.</li>
            <li>2. If an order is pending, go to the return page to manually sync the order.</li>
            <li>3. Check credits in the top bar after successful payment.</li>
          </ul>
          <Link
            href="/billing"
            className="mt-4 inline-flex text-sm font-semibold text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 dark:hover:text-indigo-300"
          >
            Go to Billing
          </Link>
        </div>

        <div className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-5 shadow-sm">
          <div className="mb-3 inline-flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-100 dark:bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
            <LifeBuoy className="h-4 w-4" />
          </div>
          <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">FAQ (Common Issues)</h2>
          <ul className="mt-3 space-y-2 text-sm text-slate-600 dark:text-slate-400">
            <li>
              1. Payment completed but order is still `PENDING`: go back to the return page and click sync, then check Billing again.
            </li>
            <li>
              2. Order is successful but credits are not added: take a screenshot of `orderId`, provider transaction id and contact support for verification.
            </li>
            <li>
              3. Job creation error: check if credits are sufficient, if preset requires an INPUT image, then try creating the job again.
            </li>
          </ul>
        </div>
      </div>

      <div className="mt-6 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-5 shadow-sm">
        <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">Contact Support</h2>
        <p className="mt-2 text-sm text-slate-600 dark:text-slate-400">
          When reporting an error, please include `userId`, `orderId`/`jobId`, timestamp, and a screenshot so the team can resolve it faster.
        </p>
        <div className="mt-4 grid grid-cols-1 gap-3 md:grid-cols-3">
          <a
            href="mailto:support@neuragen.xyz"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 dark:border-slate-700 px-4 py-2.5 text-sm font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800"
          >
            <Mail className="h-4 w-4" />
            Email Support
          </a>
          <a
            href="https://t.me/neuragen_support"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 dark:border-slate-700 px-4 py-2.5 text-sm font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800"
          >
            <MessageCircle className="h-4 w-4" />
            Telegram
          </a>
          <a
            href="https://discord.gg/neuragen"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 dark:border-slate-700 px-4 py-2.5 text-sm font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800"
          >
            <MessageCircle className="h-4 w-4" />
            Discord
          </a>
        </div>
      </div>

      {isAdmin && (
        <div className="mt-6 rounded-2xl border border-rose-200 dark:border-rose-500/30 bg-rose-50 dark:bg-rose-500/10 p-5">
          <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-rose-100 dark:bg-rose-500/20 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-rose-700 dark:text-rose-400">
            <ShieldCheck className="h-3.5 w-3.5" />
            Admin Shortcut
          </p>
          <p className="text-sm text-rose-700 dark:text-rose-400">
            You are currently in the ADMIN role.
          </p>
          <Link
            href="/admin"
            className="mt-3 inline-flex text-sm font-semibold text-rose-700 dark:text-rose-400 hover:text-rose-600 dark:hover:text-rose-300"
          >
            Open Admin Console
          </Link>

          <div className="mt-4 rounded-xl border border-rose-200 dark:border-rose-500/30 bg-white/70 dark:bg-slate-900/50 p-4">
            <h3 className="text-sm font-semibold text-rose-800 dark:text-rose-300">Admin Runbook</h3>
            <ul className="mt-2 space-y-1 text-sm text-rose-700 dark:text-rose-400/80">
              <li>
                1. Payment pending for a long time: go to Admin Console, try `Confirm Webhook` first.
              </li>
              <li>
                2. If money is actually received: use `Mark Order As Paid` with `orderId` (+ `providerOrderId` if any).
              </li>
              <li>
                3. Moderation needed: use forms to delete post/comment or remove like/follow targeting specific users.
              </li>
              <li>
                4. Only use `Manual Credit Top-up` for verified special support cases.
              </li>
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}
