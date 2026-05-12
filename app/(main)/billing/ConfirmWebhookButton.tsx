"use client";

import React, { useState } from 'react';
import { confirmPayosWebhookAction } from '@/app/actions/billing';
import { Loader2, Settings } from 'lucide-react';

export default function ConfirmWebhookButton() {
  const [isLoading, setIsLoading] = useState(false);

  const handleConfirm = async () => {
    setIsLoading(true);
    const res = await confirmPayosWebhookAction();
    setIsLoading(false);
    if (res.success) {
      alert("PayOS Webhook confirmed successfully!");
    } else {
      alert(res.error || "Failed to confirm webhook.");
    }
  };

  return (
    <button
      onClick={handleConfirm}
      disabled={isLoading}
      className="text-xs text-slate-400 hover:text-slate-600 flex items-center gap-1 mt-4 mx-auto transition-colors"
      title="Admin: Sync PayOS Webhook"
    >
      {isLoading ? <Loader2 className="w-3 h-3 animate-spin" /> : <Settings className="w-3 h-3" />}
      Sync PayOS Webhook
    </button>
  );
}
