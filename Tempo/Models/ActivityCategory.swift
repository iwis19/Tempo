//
//  ActivityCategories.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-16.
//

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
    
    var iconName: String {
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
