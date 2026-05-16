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
    <div className="mx-auto max-w-4xl py-4">
      <div className="mb-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm md:p-8">
        <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-slate-600">
          <HelpCircle className="h-3.5 w-3.5" />
          Help Center
        </p>
        <h1 className="text-3xl font-bold text-slate-900">Need a hand?</h1>
        <p className="mt-2 text-sm text-slate-600">
          Hướng dẫn nhanh cho thanh toán, credit và xử lý sự cố thường gặp.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="mb-3 inline-flex h-9 w-9 items-center justify-center rounded-xl bg-indigo-100 text-indigo-600">
            <Wallet className="h-4 w-4" />
          </div>
          <h2 className="text-lg font-semibold text-slate-900">Billing Basics</h2>
          <ul className="mt-3 space-y-2 text-sm text-slate-600">
            <li>1. Mua gói credit trong tab Billing.</li>
            <li>2. Nếu đơn pending, vào trang return để tự sync lại đơn.</li>
            <li>3. Kiểm tra credit ở topbar sau khi thanh toán thành công.</li>
          </ul>
          <Link
            href="/billing"
            className="mt-4 inline-flex text-sm font-semibold text-indigo-600 hover:text-indigo-500"
          >
            Go to Billing
          </Link>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="mb-3 inline-flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-100 text-emerald-600">
            <LifeBuoy className="h-4 w-4" />
          </div>
          <h2 className="text-lg font-semibold text-slate-900">FAQ (Common Issues)</h2>
          <ul className="mt-3 space-y-2 text-sm text-slate-600">
            <li>
              1. Thanh toán xong nhưng đơn vẫn `PENDING`: quay lại trang return rồi
              bấm sync, sau đó kiểm tra lại Billing.
            </li>
            <li>
              2. Đơn báo thành công nhưng chưa cộng credit: chụp `orderId`,
              provider transaction id và gửi support để đối soát.
            </li>
            <li>
              3. Tạo job lỗi: kiểm tra credit còn đủ, preset có yêu cầu ảnh INPUT
              hay không, rồi tạo lại job.
            </li>
          </ul>
        </div>
      </div>

      <div className="mt-6 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <h2 className="text-lg font-semibold text-slate-900">Contact Support</h2>
        <p className="mt-2 text-sm text-slate-600">
          Khi báo lỗi, vui lòng gửi kèm `userId`, `orderId`/`jobId`, timestamp và
          ảnh chụp màn hình để team xử lý nhanh hơn.
        </p>
        <div className="mt-4 grid grid-cols-1 gap-3 md:grid-cols-3">
          <a
            href="mailto:support@neuragen.xyz"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50"
          >
            <Mail className="h-4 w-4" />
            Email Support
          </a>
          <a
            href="https://t.me/neuragen_support"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50"
          >
            <MessageCircle className="h-4 w-4" />
            Telegram
          </a>
          <a
            href="https://discord.gg/neuragen"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50"
          >
            <MessageCircle className="h-4 w-4" />
            Discord
          </a>
        </div>
      </div>

      {isAdmin && (
        <div className="mt-6 rounded-2xl border border-rose-200 bg-rose-50 p-5">
          <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-rose-100 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-rose-700">
            <ShieldCheck className="h-3.5 w-3.5" />
            Admin Shortcut
          </p>
          <p className="text-sm text-rose-700">
            Bạn đang ở role ADMIN.
          </p>
          <Link
            href="/admin"
            className="mt-3 inline-flex text-sm font-semibold text-rose-700 hover:text-rose-600"
          >
            Open Admin Console
          </Link>

          <div className="mt-4 rounded-xl border border-rose-200 bg-white/70 p-4">
            <h3 className="text-sm font-semibold text-rose-800">Admin Runbook</h3>
            <ul className="mt-2 space-y-1 text-sm text-rose-700">
              <li>
                1. Payment pending lâu: vào Admin Console, thử `Confirm Webhook`
                trước.
              </li>
              <li>
                2. Nếu tiền đã nhận thực tế: dùng `Mark Order As Paid` với
                `orderId` (+ `providerOrderId` nếu có).
              </li>
              <li>
                3. Cần moderation: dùng các form xoá post/comment hoặc gỡ
                like/follow theo user mục tiêu.
              </li>
              <li>
                4. Chỉ dùng `Manual Credit Top-up` cho trường hợp support đặc biệt
                đã xác minh.
              </li>
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}
