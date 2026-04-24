import React from "react";
import MainLayout from "../../component/MainLayout";
import ProfileView from "./ProfileView";
import { fetchApi } from "@/lib/api";
import { redirect } from "next/navigation";

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
    galleryItems = await fetchApi('/gallery');
  } catch (err) {
    // Silently handle gallery fetch errors
  }

  let jobs = [];
  try {
    jobs = await fetchApi('/jobs');
  } catch (err) {
    // Silently handle jobs fetch errors
  }

  return (
    <MainLayout activePage="profile">
      <ProfileView userProfile={userProfile} galleryItems={galleryItems || []} jobs={jobs || []} />
    </MainLayout>
  );
}
