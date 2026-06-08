//
//  SignIn.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-07.
//

import Foundation
import Combine
import GoogleSignIn
import UIKit
import SwiftUI
import CryptoKit

struct SignInGoogleResult {
    let idToken: String
    let nonce: String
}

@MainActor
class SignInViewModel: ObservableObject {
    
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken, nonce: googleResult.nonce)
    }
}


@MainActor
// code copy and pasted from https://developers.google.com/identity/sign-in/ios/sign-in#before_you_begin
class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation( { [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func signInWithGoogleFlow(completion: @escaping(Result<SignInGoogleResult, Error>) -> Void){
        
        guard let rootViewController = UIApplication.getTopViewController() else {
            return
        }
        
        let nonce = randomNonceString()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let user = signInResult?.user, let idToken = user.idToken else {
                // Inspect error
                completion(.failure(NSError()))
                return
            }
            // If sign in succeeded, display the app's main content View.
            completion(.success(.init(idToken: idToken.tokenString, nonce: nonce)))
        }
    }
    
    // Source - https://stackoverflow.com/a/61624668
    // Posted by Zorayr
    // Retrieved 2026-06-08, License - CC BY-SA 4.0

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

}

// Source - https://stackoverflow.com/a/50656239
// Posted by Hardik Thakkar, modified by community. See post 'Timeline' for change history
// Retrieved 2026-06-07, License - CC BY-SA 4.0

// MARK: UIApplication extensions

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?
        .rootViewController
    ) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
