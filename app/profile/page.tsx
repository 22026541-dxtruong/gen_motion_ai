import React from "react";
import MainLayout from "../../component/MainLayout";
import ProfileView from "./ProfileView";
import { fetchApi } from "@/lib/api";
import { redirect } from "next/navigation";
export const dynamic = "force-dynamic";

export default async function ProfilePage() {
  let userProfile = null;
  let galleryItems = [];

  try {
    userProfile = await fetchApi('/users/me');
  } catch (err) {
    // Silently handle auth errors to redirect below
  }

  // Require login to access profile
  if (!userProfile) {
    redirect('/login');
  }

  try {
    const allPosts = await fetchApi('/posts', { cache: 'no-store' });
    if (Array.isArray(allPosts)) {
      galleryItems = allPosts.filter((p: any) => p.userId === userProfile.id);
    }
  } catch (err) {
    // Silently handle gallery fetch errors
  }

  let jobs = [];
  try {
    const fetchedJobs = await fetchApi('/jobs', { cache: 'no-store' });
    jobs = Array.isArray(fetchedJobs) ? fetchedJobs : [];
  } catch (err) {
    // Silently handle jobs fetch errors
  }

  // Fallback to the initial page of jobs returned in userProfile
  if (!jobs || jobs.length === 0) {
    jobs = userProfile.jobs?.data || [];
  }

  return (
    <MainLayout activePage="profile">
      <ProfileView userProfile={userProfile} galleryItems={galleryItems || []} jobs={jobs || []} />
    </MainLayout>
  );
}
