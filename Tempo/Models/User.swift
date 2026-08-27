//
//  User.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-27.
//

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
}

struct UserSettings: Codable {
    var hourlyRate: Double
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
}

// the complete account state persisted locally and synchronized with supabase
struct UserSnapshot: Codable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var profile: UserProfile
    var setting: UserSettings
    var todayStatement: DayStatement
    var pastStatements: [DayStatement]
    var updatedAt: Date

    init(
        schemaVersion: Int = UserSnapshot.currentSchemaVersion,
        profile: UserProfile,
        setting: UserSettings,
        todayStatement: DayStatement,
        pastStatements: [DayStatement],
        updatedAt: Date = Date()
    ) {
        self.schemaVersion = schemaVersion
        self.profile = profile
        self.setting = setting
        self.todayStatement = todayStatement
        self.pastStatements = pastStatements
        self.updatedAt = updatedAt
    }

    static func fresh(at date: Date = Date()) -> UserSnapshot {
        let hourlyRate = 17.95

        return UserSnapshot(
            profile: UserProfile(firstName: "Jane", lastName: "Doe"),
            setting: UserSettings(
                hourlyRate: hourlyRate,
                reminderEnabled: false,
                reminderHour: 20,
                reminderMinute: 0
            ),
            todayStatement: DayStatement(
                date: date,
                isClosed: false,
                hourlyRateSnapshot: hourlyRate
            ),
            pastStatements: [],
            updatedAt: date
        )
    }
}
