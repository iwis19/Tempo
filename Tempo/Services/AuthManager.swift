//
//  AuthManager.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-07.
//

import Supabase
import Foundation

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
    
    func checkCurrentSession() async -> AppUser? {
        do {
            let session = try await client.auth.refreshSession()
            return AppUser(id: session.user.id.uuidString, email: session.user.email)
        } catch {
            return nil
        }
    }
}
