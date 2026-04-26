import SwiftUI
import ComposeApp

@main
struct iOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
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
