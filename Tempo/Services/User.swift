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
