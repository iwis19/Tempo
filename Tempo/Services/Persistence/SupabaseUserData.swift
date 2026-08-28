//
//  SupabaseUserData.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-08-27.
//

import Foundation
import Supabase

struct SupabaseUserDataSource {
    private struct RemoteUserDataRow: Codable {
        let userID: String
        let snapshot: UserSnapshot
        let updatedAt: Date

        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case snapshot
            case updatedAt = "updated_at"
        }
    }

    private let client: SupabaseClient
    private let tableName = "TempoUserData"

    init(client: SupabaseClient) {
        self.client = client
    }

    func load(for userID: String) async throws -> UserSnapshot? {
        let rows: [RemoteUserDataRow] = try await client
            .from(tableName)
            .select()
            .eq("user_id", value: userID)
            .limit(1)
            .execute()
            .value

        guard var snapshot = rows.first?.snapshot else {
            return nil
        }

        if let serverTimestamp = rows.first?.updatedAt {
            snapshot.updatedAt = serverTimestamp
        }
        return snapshot
    }

    func save(_ snapshot: UserSnapshot, for userID: String) async throws {
        let row = RemoteUserDataRow(
            userID: userID,
            snapshot: snapshot,
            updatedAt: snapshot.updatedAt
        )

        try await client
            .from(tableName)
            .upsert(row, onConflict: "user_id")
            .execute()
    }
}