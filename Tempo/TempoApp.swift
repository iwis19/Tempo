//
//  TempoApp.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-20.
//

import SwiftUI

@main
struct TempoApp: App {
    // tempo app owns the lifetime of this database object, also using state for @observable reference obj
    @State private var userStore = UserStore()
    @State private var notificationHandler = NotificationHandler()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // since all my colors are saved in light, we have to use this color scheme or else nothing happens
        }
        .environment(userStore) // makes the app own this database
        .environment(notificationHandler)
        
        // save all data when app is swiped out
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                userStore.checkForNewDay()
            }
            
            if newPhase == .background || newPhase == .inactive {
                userStore.saveAll()
            }
        }
    }
}
