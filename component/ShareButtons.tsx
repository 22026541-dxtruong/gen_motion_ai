"use client";

import React, { useState } from "react";
import { Share2, Mail, Link as LinkIcon, Check } from "lucide-react";

interface ShareButtonsProps {
  url?: string;
  title?: string;
  shareType?: "profile" | "post";
  recipientEmail?: string | null;
  className?: string;
  iconClassName?: string;
}

export default function ShareButtons({
  url,
  title = "Check this out on Neura Gen",
  shareType = "profile",
  recipientEmail,
  className = "flex gap-3",
  iconClassName = "p-2.5 rounded-full border border-gray-200 hover:bg-gray-50 text-gray-700 transition"
}: ShareButtonsProps) {
  const [copied, setCopied] = useState(false);

  const getShareUrl = () => {
    if (typeof window === "undefined") return "";
    return url || window.location.href;
  };

  const handleShare = async () => {
    const shareUrl = getShareUrl();
    if (navigator.share) {
      try {
        await navigator.share({
          title,
          url: shareUrl,
        });
        return;
      } catch (err) {
        console.error("Share failed", err);
      }
    }
    // Fallback to copy
    handleCopy();
  };

  const handleCopy = async () => {
    const shareUrl = getShareUrl();
    try {
      await navigator.clipboard.writeText(shareUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
      alert("Link copied to clipboard!");
    } catch (err) {
      console.error("Copy failed", err);
    }
  };

  const handleMail = () => {
    if (recipientEmail) {
      window.location.href = `mailto:${recipientEmail}`;
    } else {
      const shareUrl = getShareUrl();
      const subject = encodeURIComponent(title);
      const body = encodeURIComponent(`Check this out:\n\n${shareUrl}`);
      window.location.href = `mailto:?subject=${subject}&body=${body}`;
    }
  };

  return (
    <div className={className}>
      <button 
        onClick={handleShare}
        className={iconClassName}
        title="Share"
      >
        {shareType === "profile" ? <Share2 size={20} /> : <LinkIcon size={20} />}
      </button>
      <button 
        onClick={handleMail}
        className={iconClassName}
        title={recipientEmail ? "Send Email" : "Share via Email"}
      >
        <Mail size={20} />
      </button>
    </div>
  );
}
