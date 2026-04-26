import React from 'react';
import { Wand2, Image as ImageIcon, CheckCircle2, Download, Maximize } from 'lucide-react';
import Topbar from '../../component/Topbar';
import Sidebar from '../../component/Sidebar';
import MainLayout from '@/component/MainLayout';
import { fetchApi } from '@/lib/api';
import { redirect } from 'next/navigation';
import CreateForm from './CreateForm';
import JobItem from './JobItem';

export default async function CreatePage() {
  let userProfile = null;
  try {
    userProfile = await fetchApi('/users/me');
  } catch (err) {
    // Silently handle auth errors to redirect below
  }

  if (!userProfile) {
    redirect('/login');
  }

  let jobs = [];
  try {
    jobs = await fetchApi('/jobs');
  } catch (err) {
    // Silently handle error
  }

  const credits = userProfile?.credits?.balance || 0;

  return (
    <MainLayout activePage="create">
      <div className="max-w-[1200px] mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8 relative">
        
        {/* Cột trái */}
        <div className="lg:col-span-7"> 
          <div className="lg:sticky lg:top-0 bg-white rounded-2xl p-8 shadow-sm border border-slate-100 max-h-[calc(100vh-8rem)] overflow-y-auto scrollbar-hide">
            <CreateForm credits={credits} />
          </div>
        </div>

        {/* Cột phải: Danh sách Jobs dài, cứ để nó tự nhiên kéo dài trang */}
        <div className="lg:col-span-5 flex flex-col">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-slate-900">My Recent Jobs</h3>
            <button className="text-indigo-600 text-sm font-medium hover:underline">View All</button>
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
    </MainLayout>
  );
}