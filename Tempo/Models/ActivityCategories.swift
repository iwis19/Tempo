//
//  ActivityCategories.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-16.
//

// describes the possible categories of activities: spent, earned, necessity

// using enum here as this is just a possible list of choices, no properties, no data objects.
// enum is essentially just a list of possible choices
// however, for usersettings, daystatements, its not just a choice, its different variables with different data types, so struct is used

// Codable: helps later for storing data
// CaseIterable: lets me iterate through all cases
enum ActivityCategories: String, Codable, CaseIterable {
    case earned = "earned"
    case necessity = "necessity"
    case spent = "spent"
}
