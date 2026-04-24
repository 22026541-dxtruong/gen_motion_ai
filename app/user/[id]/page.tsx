'use client';

import {
  ArrowLeft,
  Search,
  BadgeCheck,
  Rocket,
  Bot,
  Link as LinkIcon,
  Mail,
  LayoutGrid,
  Library,
  Play
} from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function UserProfile() {
    const router = useRouter();
    
  return (
    <div className="min-h-screen bg-[#FDFDFD] p-4 md:p-8 font-sans text-slate-900">
      {/* Header */}
      <header className="flex items-center justify-between mb-8 max-w-7xl mx-auto">
        <button className="p-2 hover:bg-slate-100 rounded-full transition-colors text-slate-600">
          <ArrowLeft onClick={() => router.back()} className="w-6 h-6" />
        </button>
        <div className="relative w-full max-w-2xl ml-4">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-500" />
          <input
            type="text"
            placeholder="Search creators, videos..."
            className="w-full pl-12 pr-4 py-3 rounded-full border border-slate-300 bg-white focus:outline-none focus:ring-1 focus:ring-slate-400 shadow-sm transition-shadow"
          />
        </div>
      </header>

      {/* Main Content Area */}
      <main className="max-w-7xl mx-auto">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-10">
          
          {/* Left Card: Profile Info */}
          <div className="lg:col-span-2 bg-white rounded-3xl p-6 md:p-8 border border-slate-100 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] flex flex-col sm:flex-row gap-6 sm:gap-8 items-start">
            
            {/* Avatar */}
            <div className="relative shrink-0">
              <img
                src="https://images.unsplash.com/photo-1618331835717-801e976710b2?q=80&w=256&auto=format&fit=crop"
                alt="Marcus Ray"
                className="w-32 h-32 rounded-full object-cover shadow-sm"
              />
              <div className="absolute bottom-1 right-1 bg-white rounded-full p-0.5">
                <BadgeCheck className="w-7 h-7 text-black fill-black" color="white" />
              </div>
            </div>

            {/* Details */}
            <div className="flex-1 w-full">
              <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start w-full gap-4 mb-4">
                <div>
                  <h1 className="text-2xl font-medium text-slate-900">Marcus Ray</h1>
                  <p className="text-slate-600 mt-1">@marcus_visuals</p>
                </div>
                <button className="px-8 py-2.5 rounded-full border border-slate-200 font-medium hover:bg-slate-50 transition-colors shadow-sm">
                  Follow
                </button>
              </div>
              
              <p className="text-slate-800 mb-2 leading-relaxed max-w-lg">
                Digital artist exploring the intersection of nature and cyberpunk aesthetics. Creating high-fidelity AI video loops.
              </p>
              
              <div className="flex items-center gap-2 text-slate-800 mb-6">
                <span>Based in Seattle.</span>
                <Rocket className="w-4 h-4" />
                <Bot className="w-4 h-4" />
              </div>
              
              <div className="flex gap-4 text-slate-800 text-sm">
                <span>#Cyberpunk</span>
                <span>#Surreal</span>
                <span>#VFX</span>
              </div>
            </div>
          </div>

          {/* Right Card: Stats & Links */}
          <div className="bg-white rounded-3xl p-8 border border-slate-100 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] flex flex-col justify-center">
            
            {/* Stats Row */}
            <div className="flex items-center justify-between text-center mb-8">
              <div className="flex-1">
                <div className="text-lg font-medium text-slate-900">142</div>
                <div className="text-xs mt-1.5 text-slate-500 uppercase tracking-wider">Posts</div>
              </div>
              <div className="w-px h-10 bg-slate-200"></div>
              <div className="flex-1">
                <div className="text-lg font-medium text-slate-900">24.5k</div>
                <div className="text-xs mt-1.5 text-slate-500 uppercase tracking-wider">Followers</div>
              </div>
              <div className="w-px h-10 bg-slate-200"></div>
              <div className="flex-1">
                <div className="text-lg font-medium text-slate-900">89</div>
                <div className="text-xs mt-1.5 text-slate-500 uppercase tracking-wider">Following</div>
              </div>
            </div>

            <hr className="border-slate-100 mb-8" />
            
            {/* Link Buttons */}
            <div className="flex justify-center gap-4">
              <button className="p-3 border border-slate-200 rounded-full hover:bg-slate-50 transition-colors shadow-sm text-slate-700">
                <LinkIcon className="w-5 h-5" />
              </button>
              <button className="p-3 border border-slate-200 rounded-full hover:bg-slate-50 transition-colors shadow-sm text-slate-700">
                <Mail className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-200 mb-8 px-2">
          <button className="flex items-center gap-2 pb-4 border-b-2 border-slate-900 font-medium text-slate-900">
            <LayoutGrid className="w-5 h-5" />
            Public Videos
          </button>
          <button className="flex items-center gap-2 pb-4 border-b-2 border-transparent text-slate-500 hover:text-slate-800 transition-colors">
            <Library className="w-5 h-5" />
            Collections
          </button>
        </div>

        {/* Video Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Video Item 1 */}
          <div className="relative aspect-[3/4] bg-[#111] rounded-2xl overflow-hidden group cursor-pointer">
             <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/60"></div>
             <Play className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-16 h-16 text-white/90 group-hover:scale-110 transition-transform fill-white/20" />
          </div>
          
          {/* Video Item 2 */}
          <div className="relative aspect-[3/4] bg-[#1a1a1a] rounded-2xl overflow-hidden group cursor-pointer flex items-center justify-center">
             <div className="absolute bottom-4 left-0 right-0 text-center font-bold text-2xl tracking-widest text-[#a8905b] opacity-60">E M P O W O</div>
             <Play className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-16 h-16 text-white/90 group-hover:scale-110 transition-transform fill-white/20" />
          </div>
          
          {/* Video Item 3 */}
          <div className="relative aspect-[3/4] bg-[#222] rounded-2xl overflow-hidden group cursor-pointer">
             <img src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop" className="w-full h-full object-cover opacity-80 mix-blend-overlay" alt="Video thumbnail" />
          </div>
          
          {/* Video Item 4 */}
          <div className="relative aspect-[3/4] bg-[#161616] rounded-2xl overflow-hidden group cursor-pointer">
             <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent"></div>
             <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-[#B71C1C] rounded-full p-4 group-hover:scale-110 transition-transform shadow-lg">
               <Play className="w-8 h-8 text-white fill-white" />
             </div>
          </div>
        </div>
      </main>
    </div>
  );
}