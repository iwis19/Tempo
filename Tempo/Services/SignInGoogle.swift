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

enum SignInError: LocalizedError {
    case missingRootViewController
    case missingIDToken
    
    var errorDescription: String? {
        switch self {
        case .missingRootViewController:
            return "Could not find a view controller to present Google Sign-In."
        case .missingIDToken:
            return "Google Sign-In did not return an ID token."
        }
    }
}

struct SignInGoogleResult {
    let idToken: String
}

@MainActor
class SignInViewModel: ObservableObject {
    
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken)
    }
}


@MainActor
// code copy and pasted from https://developers.google.com/identity/sign-in/ios/sign-in#before_you_begin
class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        guard let rootViewController = UIApplication.getTopViewController() else {
            throw SignInError.missingRootViewController
        }
        
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw SignInError.missingIDToken
        }
        
        return SignInGoogleResult(idToken: idToken)
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
