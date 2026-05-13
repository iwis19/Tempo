//
//  ContentView.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-20.
//

import SwiftUI

struct ContentView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(NotificationHandler.self) private var notificationHandler
    @State private var selectedTab: Tab = .dashboard
    
    private var notifHour: Int { userStore.setting.reminderHour }
    private var notifMinute: Int { userStore.setting.reminderMinute }
    private var notifEnabled: Bool { userStore.setting.reminderEnabled }

    let today = Date()
    private var time: Date? {
        Calendar.current.date(
            bySettingHour: notifHour,
            minute: notifMinute,
            second: 0,
            of: today
        )
    }
    
    var body: some View {
        
        ZStack (alignment: .bottom) {
            Group {
                switch selectedTab {
                case .dashboard:
                    NavigationStack {
                        DashboardPage()
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .today:
                    NavigationStack{
                        TodayPage()
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .history:
                    NavigationStack {
                        HistoryPage()
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .profile:
                    NavigationStack{
                        ProfilePage()
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
            
                
                BetterNavigationBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 22)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(UserStore())
        .environment(NotificationHandler())
}
