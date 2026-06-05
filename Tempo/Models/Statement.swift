//
//  DayStatement.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-16.
//

import Foundation

struct DayStatement: Identifiable, Codable {
    
    let id: UUID
    var activities: [Activity]
    var date: Date
    var isClosed: Bool
    
    var hourlyRateSnapshot: Double
    var earnedTotal: Double
    var requiredTotal: Double
    var spentTotal: Double
    var netTotal: Double
    
    init(
        id: UUID = UUID(),
        activities: [Activity] = [],
        date: Date,
        isClosed: Bool,
        hourlyRateSnapshot: Double,
        earnedTotal: Double = 0,
        requiredTotal: Double = 0,
        spentTotal: Double = 0,
        netTotal: Double = 0
    ) {
        self.id = id
        self.activities = activities
        self.date = date
        self.isClosed = isClosed
        self.hourlyRateSnapshot = hourlyRateSnapshot
        self.earnedTotal = earnedTotal
        self.requiredTotal = requiredTotal
        self.spentTotal = spentTotal
        self.netTotal = netTotal
    }
}

struct StatementSummary: Identifiable {
    let date: String
    let netTotal: Double
    let entries: Int
    let earnedMinutes: String
    let requiredMinutes: String
    let spentMinutes: String
    
    var id: String { date }
    
}
