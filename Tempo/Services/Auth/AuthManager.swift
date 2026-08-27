//
//  AuthManager.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-07.
//

import Supabase
import SwiftUI
import Foundation
import AuthenticationServices

enum SignInError: LocalizedError {
    case missingRootViewController
    case missingIDToken
    
    var errorDescription: String? {
        switch self {
        case .missingRootViewController:
            return "Could not find a view controller to present Sign-In."
        case .missingIDToken:
            return "Sign-In did not return an ID token."
        }
    }
}

struct AppUser: Identifiable {
    var id: String
    var email: String?
}

class AuthManager {
    
    static let shared = AuthManager()
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func signInWithGoogle(idToken: String, nonce: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken,
                nonce: nonce
            )
        )
        print("Supabase sign-in succeeded for user: \(session.user.id)")
        return AppUser(id: session.user.id.uuidString, email: session.user.email)
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        print("Supabase sign-in succeeded for user: \(session.user.id)")
        return AppUser(id: session.user.id.uuidString, email: session.user.email)
    }
    
    func checkCurrentSession() async -> AppUser? {
        do {
            let session = try await client.auth.refreshSession()
            return AppUser(id: session.user.id.uuidString, email: session.user.email)
        } catch {
            return nil
        }
    }
}

@MainActor
class SignInViewModel: Observable {
    
    func signInWithApple() async throws -> AppUser {
        let signInApple = SignInApple()
        let appleResult = try await signInApple.startSignInWithAppleFlow()
        return try await AuthManager.shared.signInWithApple(idToken: appleResult.idToken, nonce: appleResult.nonce)
    }
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(
            idToken: googleResult.idToken,
            nonce: googleResult.nonce
        )
    }
}

// Source - https://stackoverflow.com/a/50656239
// Posted by Hardik Thakkar, modified by community. See post 'Timeline' for change history
// Retrieved 2026-06-07, License - CC BY-SA 4.0

// MARK: UIApplication extensions, GET ROOT VIEW

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

extension UIViewController: @retroactive ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
