//
//  Activity.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-16.
//

// add support to UUID and Date, or else it is not found
import Foundation

struct Activity: Identifiable, Codable {
    
    // UUID does not behave like how it does in SQL, nor does it increment by 1 starting from 0, it generates a completely unique string of chars
    let id: UUID
    var name: String
    var durationMinutes: Int   // in minutes
    var category: ActivityCategories? // ? makes it mean that this value is optional, it could either be a real ActivityCategories value or a null (nil in Swift)
    var createdAt: Date
    
    // for UUID and ActivityCategories and Date, they are set to a value in the constructor parameters because these are set as default values, in case nothing is passed in
    init(id: UUID = UUID(), name: String, length: Int, category: ActivityCategories? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.durationMinutes = length
        self.category = category
        self.createdAt = createdAt
    }
}
