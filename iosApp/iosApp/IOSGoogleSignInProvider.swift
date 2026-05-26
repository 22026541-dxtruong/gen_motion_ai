import Foundation
import UIKit
import ComposeApp
import GoogleSignIn

class IOSGoogleSignInProvider: IosGoogleSignInProvider {
    func signIn(onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            onError("Không tìm thấy RootViewController")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            
            guard let idToken = signInResult?.user.idToken?.tokenString else {
                onError("Không lấy được ID Token")
                return
            }
            
            onSuccess(idToken)
        }
    }
}
