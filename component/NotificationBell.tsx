"use client";

import React, { useState, useEffect, useRef } from "react";
import { Bell, CheckCircle2, XCircle, Info, AlertTriangle, X } from "lucide-react";

export type JobNotificationPayload = {
  id: string; // We'll generate a local ID or use timestamp
  jobId: string;
  kind: string;
  severity: "info" | "success" | "warning" | "error";
  title: string;
  message: string;
  thumbnailUrl?: string;
  timestamp: string;
  read: boolean;
};

export default function NotificationBell() {
  const [notifications, setNotifications] = useState<JobNotificationPayload[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Load from local storage
    const saved = localStorage.getItem("neura_gen_notifications");
    if (saved) {
      try {
        setNotifications(JSON.parse(saved));
      } catch (e) {}
    }

    const sse = new EventSource('/api/notifications');

    sse.addEventListener('notification', (e) => {
      try {
        const data = JSON.parse(e.data);
        const newNotification: JobNotificationPayload = {
          ...data,
          id: data.jobId + '-' + Date.now(),
          read: false
        };
        
        setNotifications(prev => {
          // Prevent duplicates if backend resends same event closely
          if (prev.some(n => n.jobId === newNotification.jobId && n.kind === newNotification.kind)) {
            return prev;
          }
          const updated = [newNotification, ...prev].slice(0, 50); // Keep last 50
          localStorage.setItem("neura_gen_notifications", JSON.stringify(updated));
          return updated;
        });
      } catch (err) {
        console.error("Failed to parse notification", err);
      }
    });

    sse.onerror = (error) => {
      // EventSource automatically tries to reconnect
      // Removing console.error to prevent console spam
    };

    return () => {
      sse.close();
    };
  }, []);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [isOpen]);

  const unreadCount = notifications.filter(n => !n.read).length;

  const markAllAsRead = () => {
    const updated = notifications.map(n => ({ ...n, read: true }));
    setNotifications(updated);
    localStorage.setItem("neura_gen_notifications", JSON.stringify(updated));
  };

  const removeNotification = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const updated = notifications.filter(n => n.id !== id);
    setNotifications(updated);
    localStorage.setItem("neura_gen_notifications", JSON.stringify(updated));
  };

  const markAsRead = (id: string) => {
    const updated = notifications.map(n => n.id === id ? { ...n, read: true } : n);
    setNotifications(updated);
    localStorage.setItem("neura_gen_notifications", JSON.stringify(updated));
  };

  const getIcon = (severity: string) => {
    switch (severity) {
      case "success": return <CheckCircle2 className="w-5 h-5 text-green-500" />;
      case "error": return <XCircle className="w-5 h-5 text-red-500" />;
      case "warning": return <AlertTriangle className="w-5 h-5 text-amber-500" />;
      default: return <Info className="w-5 h-5 text-blue-500" />;
    }
  };

  return (
    <div className="relative" ref={dropdownRef}>
      <button 
        onClick={() => {
          setIsOpen(!isOpen);
          if (!isOpen && unreadCount > 0) markAllAsRead();
        }}
        className="relative p-2 text-gray-500 hover:text-gray-900 transition-colors rounded-full hover:bg-gray-100"
      >
        <Bell className="w-6 h-6" />
        {unreadCount > 0 && (
          <span className="absolute top-1 right-1 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white"></span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-80 sm:w-96 bg-white rounded-2xl shadow-xl border border-gray-100 z-50 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200">
          <div className="flex items-center justify-between p-4 border-b border-gray-100 bg-gray-50/50">
            <h3 className="font-semibold text-gray-900">Notifications</h3>
            {notifications.length > 0 && (
              <button onClick={() => {
                  setNotifications([]);
                  localStorage.removeItem("neura_gen_notifications");
                }} 
                className="text-xs text-gray-500 hover:text-gray-900 font-medium"
              >
                Clear all
              </button>
            )}
          </div>
          
          <div className="max-h-[400px] overflow-y-auto custom-scrollbar">
            {notifications.length === 0 ? (
              <div className="p-8 text-center text-gray-500 text-sm">
                No notifications yet.
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {notifications.map(notif => (
                  <div 
                    key={notif.id} 
                    onClick={() => markAsRead(notif.id)}
                    className={`p-4 hover:bg-gray-50 transition-colors cursor-pointer group relative ${!notif.read ? 'bg-indigo-50/30' : ''}`}
                  >
                    <div className="flex gap-3">
                      <div className="flex-shrink-0 mt-0.5 relative">
                        {notif.thumbnailUrl ? (
                          <>
                            <img src={notif.thumbnailUrl} alt="thumbnail" className="w-10 h-10 rounded-lg object-cover bg-gray-200" />
                            <div className="absolute -bottom-1 -right-1 bg-white rounded-full p-0.5 shadow-sm">
                              {React.cloneElement(getIcon(notif.severity), { className: "w-3 h-3 text-current" })}
                            </div>
                          </>
                        ) : (
                          getIcon(notif.severity)
                        )}
                      </div>
                      <div className="flex-1 min-w-0 pr-6">
                        <p className={`text-sm ${!notif.read ? 'font-semibold text-gray-900' : 'font-medium text-gray-700'} truncate`}>{notif.title}</p>
                        <p className="text-sm text-gray-600 line-clamp-2 mt-0.5 leading-snug">{notif.message}</p>
                        <p className="text-xs text-gray-400 mt-1">
                          {new Date(notif.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </p>
                      </div>
                    </div>
                    <button 
                      onClick={(e) => removeNotification(notif.id, e)}
                      className="absolute right-3 top-3 p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md opacity-0 group-hover:opacity-100 transition-all"
                    >
                      <X className="w-4 h-4" />
                    </button>
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
