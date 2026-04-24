import Sidebar from "./Sidebar";
import Topbar from "./Topbar"

interface MainLayoutProps {
  children: React.ReactNode;
  activePage?: 'explore' | 'create' | 'profile' | 'billing';
}

const MainLayout = ({
  children,
  activePage = 'explore',
}: MainLayoutProps) => {
    return (
    
    <div className="h-screen w-full overflow-hidden bg-[#f8f9fa] text-slate-900 font-sans flex flex-col">
      <Topbar />

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