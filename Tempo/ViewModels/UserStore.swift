//
//  UserStore.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-27.
//

import Observation
import Foundation

// observable: swiftui reacts when an object of this type changes, its more about watching the object
// state: swiftui also reacts with an object changes, but its more about owning the var than updating
@Observable
final class UserStore {
    var setting: UserSettings
    var profile: UserProfile
    
    private let defaults = UserDefaults.standard
    
    init()
    {
        profile = UserProfile(
            firstName: defaults.string(forKey: "firstName") ?? "Jane",
            lastName: defaults.string(forKey: "lastName") ?? "Doe"
        )
        setting = UserSettings(
            // reads the data from under the "hourlyRate" key in defaults database, if it doesnt exist, return 17.95 default
            hourlyRate: defaults.object(forKey: "hourlyRate") as? Double ?? 17.95,
            reminderEnabled: defaults.object(forKey: "reminderEnabled") as? Bool ?? false,
            reminderHour: defaults.object(forKey: "reminderHour") as? Int ?? 20,
            reminderMinute: defaults.object(forKey: "reminderMinute") as? Int ?? 0
        )
    }
    
    func saveSetting (){
        // sets setting.hourlyRate to under the "hourlyRate" key in the defaults database
        defaults.set(setting.hourlyRate, forKey: "hourlyRate")
        defaults.set(setting.reminderEnabled, forKey: "reminderEnabled")
        defaults.set(setting.reminderHour, forKey: "reminderHour")
        defaults.set(setting.reminderMinute, forKey: "reminderMinute")
    }
    
    func saveProfile(){
        defaults.set(profile.firstName, forKey: "firstName")
        defaults.set(profile.lastName, forKey: "lastName")
    }
}
