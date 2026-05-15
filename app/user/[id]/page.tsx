import {
  ArrowLeft,
  BadgeCheck,
  ShieldCheck,
  Rocket,
  Bot,
  LayoutGrid,
} from 'lucide-react';
import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { getUserByIdAction, checkFollowStatusAction } from '@/app/actions/user';
import { fetchApi } from '@/lib/api';
import UserVideoCard from './UserVideoCard';
import FollowButton from './FollowButton';
import ShareButtons from "../../../component/ShareButtons";

type PublicPost = {
  id: string;
  userId: string;
  [key: string]: unknown;
};

export default async function UserProfile({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = await params;
  const userId = resolvedParams.id;
  
  const userRes = await getUserByIdAction(userId);
  if (!userRes.success || !userRes.data) {
    notFound();
  }
  const user = userRes.data;

  let currentUser = null;
  try {
    currentUser = await fetchApi('/users/me');
  } catch {
    // Guest user
  }

  // Redirect to profile if this is the current user
  if (currentUser && currentUser.id === user.id) {
    redirect('/profile');
  }

  let isFollowing = false;
  if (currentUser) {
    const followStatus = await checkFollowStatusAction(user.id);
    isFollowing = followStatus.isFollowing;
  }

  let userPosts: PublicPost[] = [];
  try {
    const allPosts = await fetchApi('/posts');
    if (Array.isArray(allPosts)) {
      userPosts = allPosts.filter((p): p is PublicPost => (
        typeof p === 'object' &&
        p !== null &&
        typeof (p as PublicPost).id === 'string' &&
        typeof (p as PublicPost).userId === 'string' &&
        (p as PublicPost).userId === user.id
      ));
    }
  } catch (error) {
    console.error("Failed to fetch posts:", error);
  }

  return (
    <div className="min-h-screen bg-[#FDFDFD] p-4 md:p-8 font-sans text-slate-900">
      {/* Header */}
      <header className="flex items-center justify-between mb-8 max-w-7xl mx-auto">
        <Link href="/explore" className="p-2 hover:bg-slate-100 rounded-full transition-colors text-slate-600 block">
          <ArrowLeft className="w-6 h-6" />
        </Link>
      </header>

      {/* Main Content Area */}
      <main className="max-w-7xl mx-auto">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-10">
          
          {/* Left Card: Profile Info */}
          <div className="lg:col-span-2 bg-white rounded-3xl p-6 md:p-8 border border-slate-100 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] flex flex-col sm:flex-row gap-6 sm:gap-8 items-start">
            
            {/* Avatar */}
            <div className="relative inline-block w-fit">
              <img
                src={user.avatarUrl || `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username)}&background=e0e7ff&color=4f46e5`}
                alt={user.username}
                className="w-32 h-32 rounded-full object-cover shadow-sm bg-slate-100"
              />
              {user.role === 'PRO' && (
                <div className="absolute bottom-1 right-1 bg-white rounded-full p-0.5">
                  <BadgeCheck className="w-7 h-7 text-indigo-600 fill-indigo-600" color="white" />
                </div>
              )}
              {user.role === 'ADMIN' && (
                <div className="absolute bottom-1 right-1 bg-white rounded-full p-0.5">
                  <ShieldCheck className="w-7 h-7 text-rose-600 fill-rose-600" color="white" />
                </div>
              )}
            </div>

            {/* Details */}
            <div className="flex-1 w-full">
              <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start w-full gap-4 mb-4">
                <div>
                  <h1 className="text-2xl font-medium text-slate-900">{user.username}</h1>
                  <p className="text-slate-600 mt-1">@{user.username}</p>
                </div>
                <FollowButton 
                  userId={user.id} 
                  initialIsFollowing={isFollowing} 
                  isAuthenticated={!!currentUser} 
                />
              </div>
              
              <p className="text-slate-800 mb-2 leading-relaxed max-w-lg">
                {user.bio || "No bio available."}
              </p>
              
              <div className="flex items-center gap-2 text-slate-800 mb-6">
                <Rocket className="w-4 h-4 text-indigo-600" />
                <Bot className="w-4 h-4 text-purple-600" />
              </div>
            </div>
          </div>

          {/* Right Card: Stats & Links */}
          <div className="bg-white rounded-3xl p-8 border border-slate-100 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] flex flex-col justify-center">
            
            {/* Stats Row */}
            <div className="flex items-center justify-between text-center mb-8">
              <div className="flex-1">
                <div className="text-lg font-medium text-slate-900">{user.counts?.posts || 0}</div>
                <div className="text-xs mt-1.5 text-slate-500 uppercase tracking-wider">Posts</div>
              </div>
              <div className="w-px h-10 bg-slate-200"></div>
              <div className="flex-1">
                <div className="text-lg font-medium text-slate-900">{user.counts?.followers || 0}</div>
                <div className="text-xs mt-1.5 text-slate-500 uppercase tracking-wider">Followers</div>
              </div>
              <div className="w-px h-10 bg-slate-200"></div>
              <div className="flex-1">
                <div className="text-lg font-medium text-slate-900">{user.counts?.following || 0}</div>
                <div className="text-xs mt-1.5 text-slate-500 uppercase tracking-wider">Following</div>
              </div>
            </div>

            <hr className="border-slate-100 mb-8" />
            
            {/* Link Buttons */}
            <ShareButtons 
              title={`${user.username}'s Profile on Neura Gen`} 
              className="flex justify-center gap-4" 
              iconClassName="p-3 border border-slate-200 rounded-full hover:bg-slate-50 transition-colors shadow-sm text-slate-700" 
            />
          </div>
        </div>

        {/* Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-200 mb-8 px-2">
          <button className="flex items-center gap-2 pb-4 border-b-2 border-slate-900 font-medium text-slate-900">
            <LayoutGrid className="w-5 h-5" />
            Public Videos
          </button>
        </div>

        {/* Video Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {userPosts.length === 0 ? (
            <div className="col-span-full py-12 text-center text-slate-500">
              No public videos available.
            </div>
          ) : (
            userPosts.map((post) => (
              <UserVideoCard key={post.id} post={post} />
            ))
          )}
        </div>
      </main>
    </div>
  );
}
