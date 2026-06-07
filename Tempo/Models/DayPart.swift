//
//  Flowtone.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-26.
//

import Foundation

enum DayPart: CaseIterable {
    case midnight
    case morning
    case noon
    case afternoon
    case evening
    
    static func of(_ timeOfDate: Date) -> DayPart {
        let hour = Calendar.current.component(.hour, from: timeOfDate)
        
        switch hour {
        case 0..<5:
            return .midnight
        case 5..<12:
            return .morning
        case 12..<14:
            return .noon
        case 14..<18:
            return .afternoon
        default:
            return .evening
        }
    }
    
    var title: String {
        switch self {
        case .midnight:
            return "Midnight"
        case .morning:
            return "Morning"
        case .noon:
            return "Noon"
        case .afternoon:
            return "Afternoon"
        case .evening:
            return "Evening"
        }
    }
}


