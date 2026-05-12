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
      <div className="h-screen w-full overflow-hidden bg-[#f8f9fa] text-slate-900 font-sans flex flex-col">
        <Topbar />

        <div className="flex flex-1 overflow-hidden">
          <Sidebar />

          <main className="flex-1 overflow-y-auto p-8 bg-white relative">
            {children}
          </main>
        </div>
      </div>
    </SWRProvider>
  );
}
