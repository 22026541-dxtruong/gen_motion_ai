import { cookies } from 'next/headers';
import { NextRequest } from 'next/server';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

/**
 * SSE Proxy for GET /jobs/:id/events
 *
 * The browser's native EventSource cannot attach custom headers (Authorization).
 * This API route reads the accessToken from the HTTP-only cookie and proxies
 * the SSE stream from the backend to the client.
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id: jobId } = await params;
  const cookieStore = await cookies();
  const token = cookieStore.get('accessToken')?.value;

  if (!token) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const backendUrl = `${API_URL}/jobs/${jobId}/events`;

  try {
    const backendRes = await fetch(backendUrl, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'text/event-stream',
      },
      // Disable Next.js caching for streaming responses
      cache: 'no-store',
    });

    if (!backendRes.ok) {
      const errorBody = await backendRes.text();
      return new Response(errorBody, {
        status: backendRes.status,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    if (!backendRes.body) {
      return new Response(JSON.stringify({ error: 'No stream body from backend' }), {
        status: 502,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Forward the stream from the backend to the client
    return new Response(backendRes.body, {
      status: 200,
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache, no-transform',
        'Connection': 'keep-alive',
        'X-Accel-Buffering': 'no', // Disable buffering in Nginx if present
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Failed to connect to backend SSE' }), {
      status: 502,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
