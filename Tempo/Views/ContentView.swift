//
//  ContentView.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-20.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    
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
}
