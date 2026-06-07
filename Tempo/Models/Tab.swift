//
//  Tab.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-07.
//

enum Tab {
    case home
    case profile
    case today
    case history
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .profile: return "Profile"
        case .today: return "Today"
        case .history: return "History"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.crop.circle"
        case .today: return "sun.max"
        case .history: return "clock.arrow.circlepath"
        }
    }
    
}
