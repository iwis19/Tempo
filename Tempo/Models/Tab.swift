//
//  Tab.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-26.
//

enum Tab {
    case dashboard
    case profile
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.crop.circle"
        }
    }
}
