'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Wand2, Image as ImageIcon, X } from 'lucide-react';
import { uploadAssetAction, createVideoJobAction } from '@/app/actions/job';
import { useSWRConfig } from 'swr';

import { PRESETS } from '@/lib/constants';

export default function CreateForm({ credits }: { credits: number }) {
  const { mutate } = useSWRConfig();
  const [prompt, setPrompt] = useState('');
  const [negativePrompt, setNegativePrompt] = useState('');
  const [presetId, setPresetId] = useState(PRESETS[1].id); // Default to Standard
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (error) {
      const timer = setTimeout(() => {
        setError(null);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [error]);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      if (file.size > 10 * 1024 * 1024) {
        setError('Image must be under 10MB');
        return;
      }
      setImageFile(file);
      setImagePreview(URL.createObjectURL(file));
      setError(null);
    }
  };

  const removeImage = () => {
    setImageFile(null);
    setImagePreview(null);
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const handleSubmit = async () => {
    if (!prompt.trim()) {
      setError('Video prompt is required');
      return;
    }
    
    const selectedPreset = PRESETS.find((preset) => preset.id === presetId);
    if (selectedPreset?.workflow === 'I2V' && !imageFile) {
      setError('This preset requires an input image. Please upload an image first.');
      return;
    }

    setIsLoading(true);
    setError(null);
    let inputAssetId: string | undefined;

    try {
      // 1. Upload image if present
      if (imageFile) {
        const formData = new FormData();
        formData.append('file', imageFile);
        // Optional fields from API spec
        formData.append('type', 'IMAGE');
        formData.append('role', 'INPUT');

        const uploadRes = await uploadAssetAction(formData);
        if (!uploadRes.success || !uploadRes.asset?.id) {
          throw new Error(uploadRes.error || 'Failed to upload image reference');
        }
        inputAssetId = uploadRes.asset.id;
      }

      // 2. Create job
      const jobRes = await createVideoJobAction({
        prompt,
        negativePrompt: negativePrompt || undefined,
        presetId,
        inputAssetId,
        // includeBackgroundAudio: true,
      });

      if (!jobRes.success) {
        throw new Error(jobRes.error);
      }

      // Success: clear form, refresh caches
      setPrompt('');
      setNegativePrompt('');
      removeImage();
      mutate('/api/proxy/jobs');
      mutate('/api/proxy/users/me');
    } catch (err: any) {
      setError(err.message || 'An unexpected error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-3 text-indigo-600">
          <Wand2 className="h-6 w-6" />
          <h2 className="text-2xl font-bold">Generate video</h2>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-sm text-slate-500 font-medium">Credits: <span className="text-indigo-600 font-bold">{credits}</span></span>
          <span className="bg-indigo-50 text-indigo-600 text-xs font-bold px-3 py-1 rounded-full">
            AI v2.5 Active
          </span>
        </div>
      </div>

      {error && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 animate-in slide-in-from-bottom-5 fade-in duration-300">
          <div className="bg-slate-900 text-white px-6 py-3 rounded-full shadow-[0_8px_30px_rgb(0,0,0,0.12)] flex items-center gap-3 border border-slate-800">
            <span className="text-sm font-medium">{error}</span>
            <button onClick={() => setError(null)} className="text-slate-400 hover:text-white transition-colors">
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}

      {/* Video Prompt */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-slate-700 mb-2">Video Prompt</label>
        <textarea
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl p-4 text-sm outline-none focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400 transition-all resize-none h-32 placeholder:text-slate-400"
          placeholder="Describe the scene you want to bring to life..."
        ></textarea>
      </div>

      {/* Negative Prompt */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-slate-700 mb-2">Negative Prompt (Optional)</label>
        <input
          type="text"
          value={negativePrompt}
          onChange={(e) => setNegativePrompt(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl p-4 text-sm outline-none focus:ring-2 focus:ring-indigo-100 focus:border-indigo-400 transition-all placeholder:text-slate-400"
          placeholder="Low quality, blurry, distorted faces..."
        />
      </div>

      {/* Image Reference */}
      <div className="mb-8">
        <label className="block text-sm font-medium text-slate-700 mb-2">Image Reference (I2V)</label>
        
        <input 
          type="file" 
          ref={fileInputRef} 
          onChange={handleImageChange} 
          accept="image/*" 
          className="hidden" 
        />
        
        {!imagePreview ? (
          <div 
            onClick={() => fileInputRef.current?.click()}
            className="border-2 border-dashed border-slate-200 rounded-xl p-8 flex flex-col items-center justify-center text-center cursor-pointer hover:bg-slate-50 hover:border-indigo-300 transition-colors"
          >
            <ImageIcon className="h-8 w-8 text-slate-400 mb-3" />
            <p className="text-slate-600 font-medium mb-1">Click to upload or drag an image</p>
            <p className="text-slate-400 text-xs">JPG, PNG up to 10MB</p>
          </div>
        ) : (
          <div className="relative w-fit">
            <img src={imagePreview} alt="Reference" className="h-32 rounded-xl object-cover border border-slate-200" />
            <button 
              onClick={removeImage}
              className="absolute -top-2 -right-2 bg-white text-slate-500 hover:text-red-500 rounded-full p-1 shadow-md border border-slate-100 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

      {/* Generation Preset */}
      <div className="mb-8">
        <label className="block text-sm font-medium text-slate-700 mb-2">Generation Preset</label>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {PRESETS.map((preset) => {
            const isSelected = presetId === preset.id;
            return (
              <button 
                key={preset.id}
                onClick={() => setPresetId(preset.id)}
                className={`rounded-xl p-4 flex flex-col items-center justify-center transition-colors ${
                  isSelected 
                    ? 'border-2 border-indigo-500 bg-indigo-50' 
                    : 'border border-slate-200 hover:border-indigo-300'
                }`}
              >
                <span className={`font-medium mb-1 ${isSelected ? 'text-indigo-700' : 'text-slate-700'}`}>
                  {preset.label}
                </span>
                <span className={`text-xs ${isSelected ? 'text-indigo-500' : 'text-slate-400'}`}>
                  {preset.duration} • {preset.cost} {preset.cost === 1 ? 'Credit' : 'Credits'}
                </span>
                <span className={`text-[10px] mt-1 ${isSelected ? 'text-indigo-400' : 'text-slate-400'}`}>
                  {preset.workflow}
                </span>
              </button>
            )
          })}
        </div>
      </div>

      {/* Submit Button */}
      <button 
        onClick={handleSubmit}
        disabled={isLoading}
        className="w-full bg-[#8b5cf6] hover:bg-[#7c3aed] text-white font-medium py-4 rounded-xl flex items-center justify-center gap-2 transition-colors shadow-md shadow-violet-200 disabled:opacity-70 disabled:cursor-not-allowed"
      >
        <Wand2 className="h-5 w-5" />
        {isLoading ? 'Processing...' : 'Generate video'}
      </button>
    </>
  );
}
