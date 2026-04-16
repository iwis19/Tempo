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
    
    init(id: UUID = UUID(), activities: [Activity] = [], date: Date, isClosed: Bool) {
        self.id = id
        self.activities = activities
        self.date = date
        self.isClosed = isClosed
    }
    
}
