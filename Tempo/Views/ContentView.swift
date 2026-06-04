//
//  ContentView.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-20.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    @State private var showLaunchPage = true

    var body: some View {
        ZStack {
            if showLaunchPage {
                LaunchPage()
                    .transition(.opacity)
            }
            else {
                mainContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               withAnimation() {
                   showLaunchPage = false
               }
           }
        }
        
    }
    
    private var mainContent: some View {
        ZStack (alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        HomePage()
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
