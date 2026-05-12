'use client';

import React from "react";
import ProfileView from "./ProfileView";
import { useUser, useJobs } from "@/lib/swr";
import useSWR from "swr";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

export default function ProfilePage() {
  const { user, isLoading: userLoading } = useUser();
  const { jobs, isLoading: jobsLoading } = useJobs();
  const router = useRouter();

  // Fetch user's posts
  const { data: allPosts } = useSWR(
    user?.id ? '/api/proxy/posts' : null,
    { dedupingInterval: 30000 }
  );

  // Redirect if not authenticated
  React.useEffect(() => {
    if (!userLoading && !user) {
      router.push('/login');
    }
  }, [user, userLoading, router]);

  if (userLoading || jobsLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
      </div>
    );
  }

  if (!user) return null;

  const galleryItems = Array.isArray(allPosts)
    ? allPosts.filter((p: any) => p.userId === user.id)
    : [];

  return (
    <ProfileView
      userProfile={user}
      galleryItems={galleryItems}
      jobs={jobs || []}
    />
  );
}
