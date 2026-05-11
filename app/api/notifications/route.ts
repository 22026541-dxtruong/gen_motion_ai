import { cookies } from 'next/headers';
import { buildApiUrl } from '@/lib/runtime-config';

export async function GET() {
  const cookieStore = await cookies();
  const token = cookieStore.get('accessToken')?.value;

  if (!token) {
    return new Response('Unauthorized', { status: 401 });
  }

  const backendUrl = buildApiUrl('/jobs/events/me');
  
  try {
    const response = await fetch(backendUrl, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    if (!response.ok) {
      return new Response('Failed to connect to SSE stream', { status: response.status });
    }

    return new Response(response.body, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache, no-transform',
        'Connection': 'keep-alive',
      }
    });
  } catch (error) {
    return new Response('Internal Server Error', { status: 500 });
  }
}
