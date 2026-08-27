//
//  LocalUserData.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-08-27.
//

import Foundation
import Supabase

// persists each Supabase account under a separate local key.
struct LocalUserDataSource {
    private enum LegacyKey {
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let hourlyRate = "hourlyRate"
        static let reminderEnabled = "reminderEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
        static let todayStatement = "todayStatement"
        static let pastStatements = "pastStatements"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(for userID: String) -> UserSnapshot? {
        if let data = defaults.data(forKey: storageKey(for: userID)),
           let snapshot = try? decoder.decode(UserSnapshot.self, from: data) {
            return snapshot
        }

        return migrateLegacyDataIfNeeded(to: userID)
    }

    func save(_ snapshot: UserSnapshot, for userID: String) throws {
        let data = try encoder.encode(snapshot)
        defaults.set(data, forKey: storageKey(for: userID))
    }

    private func storageKey(for userID: String) -> String {
        "tempo.user.\(userID).snapshot.v\(UserSnapshot.currentSchemaVersion)"
    }

    // claims the pre-account UserDefaults data for the first authenticated user on this installation
    private func migrateLegacyDataIfNeeded(to userID: String) -> UserSnapshot? {
        let ownerKey = "tempo.legacyDataOwnerUserID"

        if let migrationOwner = defaults.string(forKey: ownerKey), migrationOwner != userID {
            return nil
        }

        let legacyKeys = [
            LegacyKey.firstName,
            LegacyKey.lastName,
            LegacyKey.hourlyRate,
            LegacyKey.reminderEnabled,
            LegacyKey.reminderHour,
            LegacyKey.reminderMinute,
            LegacyKey.todayStatement,
            LegacyKey.pastStatements
        ]

        guard legacyKeys.contains(where: { defaults.object(forKey: $0) != nil }) else {
            return nil
        }

        let hourlyRate = defaults.object(forKey: LegacyKey.hourlyRate) as? Double ?? 17.95
        let profile = UserProfile(
            firstName: defaults.string(forKey: LegacyKey.firstName) ?? "Jane",
            lastName: defaults.string(forKey: LegacyKey.lastName) ?? "Doe"
        )
        let setting = UserSettings(
            hourlyRate: hourlyRate,
            reminderEnabled: defaults.object(forKey: LegacyKey.reminderEnabled) as? Bool ?? false,
            reminderHour: defaults.object(forKey: LegacyKey.reminderHour) as? Int ?? 20,
            reminderMinute: defaults.object(forKey: LegacyKey.reminderMinute) as? Int ?? 0
        )

        let todayStatement: DayStatement
        if let data = defaults.data(forKey: LegacyKey.todayStatement),
           let decoded = try? decoder.decode(DayStatement.self, from: data) {
            todayStatement = decoded
        } else {
            todayStatement = DayStatement(
                date: Date(),
                isClosed: false,
                hourlyRateSnapshot: hourlyRate
            )
        }

        let pastStatements: [DayStatement]
        if let data = defaults.data(forKey: LegacyKey.pastStatements),
           let decoded = try? decoder.decode([DayStatement].self, from: data) {
            pastStatements = decoded
        } else {
            pastStatements = []
        }

        let snapshot = UserSnapshot(
            profile: profile,
            setting: setting,
            todayStatement: todayStatement,
            pastStatements: pastStatements
        )

        do {
            try save(snapshot, for: userID)
            defaults.set(userID, forKey: ownerKey)
            return snapshot
        } catch {
            return nil
        }
    }
}