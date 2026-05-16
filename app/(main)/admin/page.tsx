"use client";

import React, { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Loader2, ShieldCheck } from "lucide-react";
import { useUser } from "@/lib/swr";
import BillingAdminPanel from "../billing/BillingAdminPanel";
import AdminModerationPanel from "../billing/AdminModerationPanel";

export default function AdminPage() {
  const router = useRouter();
  const { user, isLoading } = useUser();

  useEffect(() => {
    if (!isLoading && user?.role !== "ADMIN") {
      router.replace("/explore");
    }
  }, [isLoading, router, user?.role]);

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
      </div>
    );
  }

  if (user?.role !== "ADMIN") {
    return null;
  }

  return (
    <div className="mx-auto max-w-6xl py-4">
      <div className="mb-8 rounded-3xl border border-indigo-100 bg-gradient-to-br from-indigo-50 via-white to-cyan-50 p-6 md:p-8">
        <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-indigo-100 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-indigo-700">
          <ShieldCheck className="h-3.5 w-3.5" />
          ADMIN ONLY
        </p>
        <h1 className="text-3xl font-bold text-slate-900">Admin Console</h1>
        <p className="mt-2 text-sm text-slate-600">
          Quản trị thanh toán, credit và moderation cho NeuraGen. Hãy cẩn thận khi thực hiện các thay đổi ở đây, vì chúng có thể ảnh hưởng đến trải nghiệm của người dùng và hoạt động của hệ thống.
        </p>
      </div>

      <BillingAdminPanel />
      <AdminModerationPanel />
    </div>
  );
}
