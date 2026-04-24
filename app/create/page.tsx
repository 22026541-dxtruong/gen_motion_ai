import React from 'react';
import { Wand2, Image as ImageIcon, CheckCircle2, Download, Maximize } from 'lucide-react';
import Topbar from '../../component/Topbar';
import Sidebar from '../../component/Sidebar';
import MainLayout from '@/component/MainLayout';

const CreatePage = () => {
  return (
    <MainLayout activePage="create">
          <div className="max-w-[1200px] mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8">
            
            {/* Left Panel: Generate Form */}
            <div className="lg:col-span-7 bg-white rounded-2xl p-8 shadow-sm border border-slate-100 h-fit">
              <div className="flex items-center justify-between mb-8">
                <div className="flex items-center gap-3 text-indigo-600">
                  <Wand2 className="h-6 w-6" />
                  <h2 className="text-2xl font-bold">Generate video</h2>
                </div>
                <span className="bg-indigo-50 text-indigo-600 text-xs font-bold px-3 py-1 rounded-full">
                  AI v2.5 Active
                </span>
              </div>

              {/* Video Prompt */}
              <div className="mb-6">
                <label className="block text-sm font-medium text-slate-700 mb-2">Video Prompt</label>
                <textarea
                  className="w-full bg-white border border-slate-200 rounded-xl p-4 text-sm outline-none focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400 transition-all resize-none h-32 placeholder:text-slate-400"
                  placeholder="Describe the scene you want to bring to life..."
                ></textarea>
              </div>

              {/* Negative Prompt */}
              <div className="mb-6">
                <label className="block text-sm font-medium text-slate-700 mb-2">Negative Prompt (Optional)</label>
                <input
                  type="text"
                  className="w-full bg-white border border-slate-200 rounded-xl p-4 text-sm outline-none focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400 transition-all placeholder:text-slate-400"
                  placeholder="Low quality, blurry, distorted faces..."
                />
              </div>

              {/* Image Reference */}
              <div className="mb-8">
                <label className="block text-sm font-medium text-slate-700 mb-2">Image Reference (I2V)</label>
                <div className="border-2 border-dashed border-slate-200 rounded-xl p-8 flex flex-col items-center justify-center text-center cursor-pointer hover:bg-slate-50 transition-colors">
                  <ImageIcon className="h-8 w-8 text-slate-400 mb-3" />
                  <p className="text-slate-600 font-medium mb-1">Click to upload or drag an image</p>
                  <p className="text-slate-400 text-xs">JPG, PNG up to 10MB</p>
                </div>
              </div>

              {/* Generation Preset */}
              <div className="mb-8">
                <label className="block text-sm font-medium text-slate-700 mb-2">Generation Preset</label>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <button className="border border-slate-200 rounded-xl p-4 flex flex-col items-center justify-center hover:border-indigo-300 transition-colors">
                    <span className="font-medium text-slate-700 mb-1">Preview</span>
                    <span className="text-xs text-slate-400">2s • 1 Credit</span>
                  </button>
                  <button className="border-2 border-indigo-500 bg-indigo-50 rounded-xl p-4 flex flex-col items-center justify-center transition-colors">
                    <span className="font-medium text-indigo-700 mb-1">Standard</span>
                    <span className="text-xs text-indigo-500">4s • 5 Credits</span>
                  </button>
                  <button className="border border-slate-200 rounded-xl p-4 flex flex-col items-center justify-center hover:border-indigo-300 transition-colors">
                    <span className="font-medium text-slate-700 mb-1">Quality</span>
                    <span className="text-xs text-slate-400">8s • 12 Credits</span>
                  </button>
                  <button className="border border-slate-200 rounded-xl p-4 flex flex-col items-center justify-center hover:border-indigo-300 transition-colors">
                    <span className="font-medium text-slate-700 mb-1">Turbo</span>
                    <span className="text-xs text-slate-400">4s • 8 Credits</span>
                  </button>
                </div>
              </div>

              {/* Submit Button */}
              <button className="w-full bg-[#8b5cf6] hover:bg-[#7c3aed] text-white font-medium py-4 rounded-xl flex items-center justify-center gap-2 transition-colors shadow-md shadow-violet-200">
                <Wand2 className="h-5 w-5" />
                Generate video
              </button>
            </div>

            {/* Right Panel: Recent Jobs */}
            <div className="lg:col-span-5 flex flex-col">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-slate-900">My Recent Jobs</h3>
                <button className="text-indigo-600 text-sm font-medium hover:underline">View All</button>
              </div>

              <div className="space-y-4">
                {/* Processing Job */}
                <div className="bg-white rounded-2xl p-6 shadow-sm border border-indigo-100 relative overflow-hidden">
                  <div className="absolute top-0 left-0 w-1 h-full bg-indigo-500"></div>
                  <div className="flex items-center justify-between mb-5">
                    <div className="flex items-center gap-2">
                      <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></div>
                      <span className="text-xs font-bold text-slate-700 tracking-wide">LIVE SSE CONNECTION</span>
                    </div>
                    <span className="bg-indigo-50 text-indigo-600 text-xs font-bold px-2.5 py-1 rounded-md">PROCESSING</span>
                  </div>

                  <div className="flex gap-4 mb-5">
                    <div className="h-[88px] w-[88px] rounded-lg overflow-hidden shrink-0 relative">
                      <img src="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=200" alt="thumb" className="w-full h-full object-cover opacity-80" />
                      <div className="absolute bottom-1 right-1 bg-black/70 text-white text-[10px] px-1 rounded">Frame: 156/240</div>
                    </div>
                    <div className="flex-1 flex flex-col justify-center">
                      <h4 className="font-semibold text-slate-900 line-clamp-1 mb-1">Futuristic cityscape at...</h4>
                      <p className="text-xs text-slate-500 mb-4">ID: #VGEN-8924</p>
                      <div className="flex items-center justify-between text-xs text-indigo-600 font-medium mb-1.5">
                        <span>Synthesizing frames ...</span>
                        <span>65%</span>
                      </div>
                      <div className="w-full bg-slate-100 rounded-full h-1.5">
                        <div className="bg-indigo-500 h-1.5 rounded-full" style={{ width: '65%' }}></div>
                      </div>
                    </div>
                  </div>

                  {/* Terminal */}
                  <div className="bg-[#0f172a] rounded-xl p-4 text-[11px] font-mono text-slate-300 leading-[1.6]">
                    <div className="flex gap-3"><span className="text-slate-500 shrink-0">10:42:01</span><span className="text-emerald-400 shrink-0">[QUEUED]</span><span>Job initialized in region us-west-2.</span></div>
                    <div className="flex gap-3"><span className="text-slate-500 shrink-0">10:42:05</span><span className="text-blue-400 shrink-0">[ASSETS]</span><span className="flex-1">Downloading user reference image and styles...</span></div>
                    <div className="flex gap-3"><span className="text-slate-500 shrink-0">10:42:12</span><span className="text-purple-400 shrink-0">[MODEL]</span><span>Base AI v2.5 loaded.</span></div>
                  </div>
                </div>

                {/* Completed Job 1 */}
                <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100 flex flex-col gap-4">
                  <div className="flex items-center justify-between">
                    <div className="flex gap-4 items-center">
                      <img src="https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=200" alt="thumb" className="h-12 w-12 rounded-lg object-cover shrink-0" />
                      <div>
                        <h4 className="font-semibold text-slate-900 mb-0.5">Deep space nebula</h4>
                        <div className="flex items-center gap-1.5 text-xs font-medium text-emerald-600"><CheckCircle2 className="h-3.5 w-3.5" /> Completed</div>
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-3">
                    <button className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5"><Download className="h-4 w-4" /> Download</button>
                    <button className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5"><Maximize className="h-4 w-4" /> Upscale</button>
                  </div>
                </div>

                {/* Completed Job 2 */}
                <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100 flex flex-col gap-4">
                  <div className="flex items-center justify-between">
                    <div className="flex gap-4 items-center">
                      <img src="https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?auto=format&fit=crop&q=80&w=200" alt="thumb" className="h-12 w-12 rounded-lg object-cover shrink-0" />
                      <div>
                        <h4 className="font-semibold text-slate-900 mb-0.5">Neon Tokyo rainy s</h4>
                        <div className="flex items-center gap-1.5 text-xs font-medium text-emerald-600"><CheckCircle2 className="h-3.5 w-3.5" /> Completed</div>
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-3">
                    <button className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5"><Download className="h-4 w-4" /> Download</button>
                    <button className="flex-1 border border-slate-200 hover:bg-slate-50 text-slate-700 py-2.5 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-1.5"><Maximize className="h-4 w-4" /> Upscale</button>
                  </div>
                </div>

              </div>
            </div>

          </div>
        </MainLayout>
  );
};

export default CreatePage;