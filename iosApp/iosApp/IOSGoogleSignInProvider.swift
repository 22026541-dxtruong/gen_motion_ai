import Foundation
import UIKit
import ComposeApp
import GoogleSignIn

class IOSGoogleSignInProvider: IosGoogleSignInProvider {
    func signIn(completionHandler: @escaping (String?, Error?) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy RootViewController"])
            completionHandler(nil, error)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let idToken = signInResult?.user.idToken?.tokenString else {
                let tokenError = NSError(domain: "GoogleSignIn", code: -2, userInfo: [NSLocalizedDescriptionKey: "Không lấy được ID Token"])
                completionHandler(nil, tokenError)
                return
            }
            
            completionHandler(idToken, nil)
        }
    }
}
