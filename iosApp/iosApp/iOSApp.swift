import SwiftUI
import ComposeApp

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Phase 1: Register BGTask handler — MUST happen before app finishes launching.
        // This only registers the handler identifier, no Koin dependencies needed yet.
        KoinHelper.shared.registerBGTaskHandler()
        return true
    }
}

@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onAppear {
                    // Phase 2 & 3: After Koin initializes (via MainViewController),
                    // schedule recurring sync and perform an immediate data pull.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        KoinHelper.shared.startBackgroundSync()
                        KoinHelper.shared.performImmediateSync()
                    }
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "neuragen", 
              url.host == "auth", 
              url.path == "/callback" else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        var queryParams: [String: String] = [:]
        for item in queryItems {
            queryParams[item.name] = item.value ?? ""
        }
        
        KoinHelper.shared.getOAuthCallbackHandler().handleCallback(query: queryParams)
    }
}
