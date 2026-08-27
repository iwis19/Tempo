//
//  UserDataRepository.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-08-27.
//

import Foundation
import Supabase

// coordinates the local cache with the authenticated cloud record, newest complete snapshot wins
struct UserDataRepository {
    private let local: LocalUserDataSource
    private let remote: SupabaseUserDataSource

    init(
        local: LocalUserDataSource = LocalUserDataSource(),
        remote: SupabaseUserDataSource? = nil
    ) {
        self.local = local
        self.remote = remote ?? SupabaseUserDataSource(client: client)
    }

    func loadCachedSnapshot(for userID: String) -> UserSnapshot? {
        local.load(for: userID)
    }

    func saveCachedSnapshot(_ snapshot: UserSnapshot, for userID: String) throws {
        try local.save(snapshot, for: userID)
    }

    func saveRemoteSnapshot(_ snapshot: UserSnapshot, for userID: String) async throws {
        try await remote.save(snapshot, for: userID)
    }

    func synchronize(
        userID: String,
        cachedSnapshot: UserSnapshot?
    ) async throws -> UserSnapshot {
        let remoteSnapshot = try await remote.load(for: userID)

        switch (cachedSnapshot, remoteSnapshot) {
        case let (cached?, remote?):
            if cached.updatedAt >= remote.updatedAt {
                try await self.remote.save(cached, for: userID)
                return cached
            }

            try local.save(remote, for: userID)
            return remote

        case let (cached?, nil):
            try await remote.save(cached, for: userID)
            return cached

        case let (nil, remote?):
            try local.save(remote, for: userID)
            return remote

        case (nil, nil):
            let freshSnapshot = UserSnapshot.fresh()
            try local.save(freshSnapshot, for: userID)
            try await remote.save(freshSnapshot, for: userID)
            return freshSnapshot
        }
    }
}
