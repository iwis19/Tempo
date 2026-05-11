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

// final class: cannot be subclassed
final class UserStore {
    var setting: UserSettings
    var profile: UserProfile
    var todayStatement: DayStatement
    var pastStatement: [DayStatement]
    
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
        todayStatement = DayStatement(
            date: Date(),
            isClosed: false
        )
        pastStatement = []
    }
    
    func saveSetting (){
        // sets setting.hourlyRate to under the "hourlyRate" key in defaults database
        defaults.set(setting.hourlyRate, forKey: "hourlyRate")
        defaults.set(setting.reminderEnabled, forKey: "reminderEnabled")
        defaults.set(setting.reminderHour, forKey: "reminderHour")
        defaults.set(setting.reminderMinute, forKey: "reminderMinute")
    }
    
    func saveProfile(){
        defaults.set(profile.firstName, forKey: "firstName")
        defaults.set(profile.lastName, forKey: "lastName")
    }
    
    func loadTodayStatement() {
        let decoder = JSONDecoder()
        if let today = defaults.data(forKey: "todayStatement"), let decoded = try? decoder.decode(DayStatement.self, from: today) {
            todayStatement = decoded
        } else {
            todayStatement = DayStatement(
                date: Date(),
                isClosed: false
            )
        }
    }
    
    func loadPastStatement() {
        let decoder = JSONDecoder()
        if let past = defaults.data(forKey: "pastStatement"), let decoded = try? decoder.decode([DayStatement].self, from:past) {
            pastStatement = decoded
        } else {
            pastStatement = []
        }
    }
    
    func saveTodayStatement() {
        let encoder = JSONEncoder()
        let today = try? encoder.encode(todayStatement)
        defaults.set(today, forKey: "todayStatement")
    }
    
    func savePastStatement() {
        let encoder = JSONEncoder()
        let past = try? encoder.encode(pastStatement)
        defaults.set(past, forKey: "pastStatement")
    }
    
    func checkForNewDay(){
        let calendar = Calendar.current
        let today = Date()
        
        if !calendar.isDate(today, inSameDayAs: todayStatement.date) {
            
            // TODO: clear current todaystatement and append yesterday todaystatement into passtatement
            pastStatement.append(todayStatement)
            todayStatement = DayStatement(
                date: today,
                isClosed: false
            )
            
            saveTodayStatement()
            savePastStatement()
            
        }
    }
}
