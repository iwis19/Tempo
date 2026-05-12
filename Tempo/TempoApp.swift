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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(userStore) // makes the app own this database
        .environment(notificationHandler)
    }
}
