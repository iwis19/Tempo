//
//  SignInApple.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-10.
//

import AuthenticationServices
import Foundation
import CryptoKit


struct SignInAppleResult {
    let idToken: String
    let nonce: String
}

class SignInApple: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInAppleResult, Error>) -> Void)?
    
    func startSignInWithAppleFlow() async throws -> SignInAppleResult {
        try await withCheckedThrowingContinuation( { [weak self] continuation in
            self?.signInWithAppleFlow { result in
                continuation.resume(with: result)
                return
            }
        })
    }
    
    private func signInWithAppleFlow(completion: @escaping (Result<SignInAppleResult, Error>) -> Void) {
        guard let rootViewController = UIApplication.getTopViewController() else {
            completion(.failure(NSError()))
            return
        }
        
        let nonce = NonceGenerator.randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = NonceGenerator.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = rootViewController
        authorizationController.performRequests()
    }
}

extension SignInApple: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: .zero)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce, let completion = completionHandler else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                completion(.failure(NSError()))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                completion(.failure(NSError()))
                return
            }
            
            let result = SignInAppleResult(idToken: idTokenString, nonce: nonce)
            completion(.success(result))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }
}


