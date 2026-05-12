'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import CreateForm from './CreateForm';
import JobItem from './JobItem';
import { useUser, useJobs } from '@/lib/swr';
import { Loader2 } from 'lucide-react';

export default function CreatePage() {
  const { user, isLoading: userLoading } = useUser();
  const { jobs, isLoading: jobsLoading } = useJobs();
  const router = useRouter();

  useEffect(() => {
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

  const credits = user?.credits?.balance || 0;

  return (
    <div className="max-w-[1200px] mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8 relative">
      
      {/* Cột trái */}
      <div className="lg:col-span-7"> 
        <div className="lg:sticky lg:top-0 bg-white rounded-2xl p-8 shadow-sm border border-slate-100 max-h-[calc(100vh-8rem)] overflow-y-auto scrollbar-hide">
          <CreateForm credits={credits} />
        </div>
      </div>

      {/* Cột phải: Danh sách Jobs */}
      <div className="lg:col-span-5 flex flex-col">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-xl font-bold text-slate-900">My Recent Jobs</h3>
        </div>

        <div className="space-y-4">
          {jobs.length === 0 ? (
            <div className="text-center py-10 text-slate-500 text-sm">No recent jobs found.</div>
          ) : (
            jobs.map((job: any) => (
              <JobItem key={job.id} job={job} />
            ))
          )}
        </div>
      </div>

    </div>
  );
}