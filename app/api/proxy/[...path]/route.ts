import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { buildApiUrl } from '@/lib/runtime-config';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ path: string[] }> }
) {
  const { path } = await params;
  const endpoint = '/' + path.join('/');
  const cookieStore = await cookies();
  const token = cookieStore.get('accessToken')?.value;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  // Forward query params
  const { searchParams } = request.nextUrl;
  const queryString = searchParams.toString();
  const url = buildApiUrl(endpoint) + (queryString ? `?${queryString}` : '');

  try {
    const res = await fetch(url, { headers, cache: 'no-store' });
    const text = await res.text();

    if (!res.ok) {
      return NextResponse.json(
        { error: text || `API Error: ${res.status}` },
        { status: res.status }
      );
    }

    const data = text.trim() ? JSON.parse(text) : null;
    return NextResponse.json(data);
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Internal proxy error' },
      { status: 500 }
    );
  }
}
