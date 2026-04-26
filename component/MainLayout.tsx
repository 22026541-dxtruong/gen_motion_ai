import Sidebar from "./Sidebar";
import Topbar from "./Topbar"
import { fetchApi } from "@/lib/api";

interface MainLayoutProps {
  children: React.ReactNode;
  activePage?: 'explore' | 'create' | 'profile' | 'billing';
}

const MainLayout = async ({
  children,
  activePage = 'explore',
}: MainLayoutProps) => {
    let user = null;
    try {
      user = await fetchApi('/users/me');
    } catch (error) {
      console.log('User not authenticated or error fetching profile');
    }

    return (
    
    <div className="h-screen w-full overflow-hidden bg-[#f8f9fa] text-slate-900 font-sans flex flex-col">
      <Topbar user={user} />

      <div className="flex flex-1 overflow-hidden">
        <Sidebar activePage={activePage} />

        <main className="flex-1 overflow-y-auto p-8 bg-white relative">
          {children}
        </main>

        </div>
    </div>
    )
}

export default MainLayout;