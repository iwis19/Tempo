//
//  Tab.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-26.
//

enum Tab {
    case dashboard
    case profile
    case today
    case history
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .profile: return "Profile"
        case .today: return "Today"
        case .history: return "History"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.crop.circle"
        case .today: return "sun.max"
        case .history: return "clock.arrow.circlepath"
        }
    }
}
