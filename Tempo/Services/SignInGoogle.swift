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
import Security

struct SignInGoogleResult {
    let idToken: String
    let nonce: String
}


@MainActor
// code copy and pasted from https://developers.google.com/identity/sign-in/ios/sign-in#before_you_begin
class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        guard let rootViewController = UIApplication.getTopViewController() else {
            throw SignInError.missingRootViewController
        }
        
        let nonce = NonceGenerator.randomNonceString()
        let hashedNonce = NonceGenerator.sha256(nonce)
        
        let signInResult = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: nil,
            nonce: hashedNonce
        )
        
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw SignInError.missingIDToken
        }
        
        return SignInGoogleResult(idToken: idToken, nonce: nonce)
    }
    
    
}
