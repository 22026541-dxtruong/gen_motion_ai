import Sidebar from "@/component/Sidebar";
import Topbar from "@/component/Topbar";
import SWRProvider from "@/component/SWRProvider";

export default function MainGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <SWRProvider>
      <div className="h-screen w-full overflow-hidden bg-[#f8f9fa] dark:bg-slate-950 text-slate-900 dark:text-slate-100 font-sans flex flex-col">
        <Topbar />

        <div className="flex flex-1 overflow-hidden">
          <Sidebar />

          <main className="flex-1 overflow-y-auto p-8 bg-white dark:bg-[#0B0F19] relative">
            {children}
          </main>
        </div>
      </div>
    </SWRProvider>
  );
}
