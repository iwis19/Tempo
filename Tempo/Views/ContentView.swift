//
//  ContentView.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-20.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    @State private var appUser: AppUser? = nil
    
    @State private var checkingSession: Bool = true

    var body: some View {
        ZStack {
            if checkingSession {
                ProgressView()
                    .tint(.tempoLeaf)
            }
            else if appUser == nil {
                LaunchPage(appUser: $appUser)
                    .transition(.opacity)
            }
            else {
                mainContent
                    .transition(.opacity)
            }
        }
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
        }
        .task {
            appUser = await AuthManager.shared.checkCurrentSession()
            checkingSession = false
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
                        ProfilePage(appUser: $appUser)
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
