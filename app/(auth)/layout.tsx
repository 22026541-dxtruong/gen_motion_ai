import { fetchApi } from '@/lib/api';
import { redirect } from 'next/navigation';

export default async function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  let user = null;
  
  try {
    // Verify with the backend to ensure the token is actually valid.
    user = await fetchApi('/users/me');
  } catch (error) {
    // If token is invalid or missing, user remains null
  }

  if (user) {
    // If truly authenticated, redirect away from auth pages.
    // MUST BE OUTSIDE try/catch because redirect() throws an error in Next.js!
    redirect('/explore');
  }

  return <>{children}</>;
}
