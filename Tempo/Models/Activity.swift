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
    var category: ActivityCategory // ? makes it mean that this value is optional, it could either be a real ActivityCategories value or a null (nil in Swift)
    var createdAt: Date
    
    // for UUID and ActivityCategories and Date, they are set to a value in the constructor parameters because these are set as default values, in case nothing is passed in
    init(id: UUID = UUID(), name: String, length: Int, category: ActivityCategory, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.durationMinutes = length
        self.category = category
        self.createdAt = createdAt
    }
}


// describes the possible categories of activities: spent, earned, required

// using enum here as this is just a possible list of choices, no properties, no data objects.
// enum is essentially just a list of possible choices
// however, for usersettings, daystatements, its not just a choice, its different variables with different data types, so struct is used

// CaseIterable: lets me iterate through all cases, lets me do things such as ActivityCategories.allCases
enum ActivityCategory: Codable, Identifiable, CaseIterable {
    case earned
    case `required` // escape char from an assigned keyword "required" in swift
    case spent
    
    var id: Self { self }
    
    var tone: Flowtone {
        switch self {
        case .earned:
            return .positive
        case .required:
            return .neutral
        case .spent:
            return .negative
        }
    }

    var title: String {
        switch self { // self here means look at which enum option the value currently is, and then chooses cases based on that current value
        case .earned:
            return "Earned"
        case .required:
            return "Required"
        case .spent:
            return "Spent"
        }
    }

    var statementMultiplier: Double {
        switch self {
        case .earned:
            return 1
        case .required:
            return -0.3
        case .spent:
            return -1
        }
    }
    
    var icon: String {
        switch self {
        case .earned:
            return "arrow.up.right"
        case .required:
            return "minus"
        case .spent:
            return "arrow.down.right"
        }
    }
}
