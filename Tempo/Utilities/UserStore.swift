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
        let initialHourlyRate = defaults.object(forKey: "hourlyRate") as? Double ?? 17.95
        
        profile = UserProfile(
            firstName: defaults.string(forKey: "firstName") ?? "Jane",
            lastName: defaults.string(forKey: "lastName") ?? "Doe"
        )
        setting = UserSettings(
            // reads the data from under the "hourlyRate" key in defaults database, if it doesnt exist, return 17.95 default
            hourlyRate: initialHourlyRate,
            reminderEnabled: defaults.object(forKey: "reminderEnabled") as? Bool ?? false,
            reminderHour: defaults.object(forKey: "reminderHour") as? Int ?? 20,
            reminderMinute: defaults.object(forKey: "reminderMinute") as? Int ?? 0
        )
        todayStatement = DayStatement(
            date: Date(),
            isClosed: false,
            hourlyRateSnapshot: initialHourlyRate
        )
        pastStatement = []

        loadTodayStatement()
        loadPastStatement()
        checkForNewDay()
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
        }
        else {
            todayStatement = DayStatement(
                date: Date(),
                isClosed: false,
                hourlyRateSnapshot: setting.hourlyRate
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

    func saveAll() {
        saveSetting()
        saveProfile()
        saveTodayStatement()
        savePastStatement()
    }
    
    func checkForNewDay(){
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.startOfDay(for: now)
        let statementDay = calendar.startOfDay(for: todayStatement.date)
        
        if statementDay == currentDay {
            return
        }
        
        let closedStatement = StatementCalculator.snapshot(
            for: todayStatement,
            hourlyRate: setting.hourlyRate,
            isClosed: true
        )
        
        pastStatement.append(closedStatement)
        
        // adds in for between today and last saved date since app wasnt loaded to check between possibly
        var nextDay = calendar.date(byAdding: .day, value: 1, to: statementDay)
        while let missedDay = nextDay, missedDay < currentDay {
            pastStatement.append(
                DayStatement(
                    date: missedDay,
                    isClosed: true,
                    hourlyRateSnapshot: setting.hourlyRate
                )
            )
            nextDay = calendar.date(byAdding: .day, value: 1, to: missedDay)
        }
        
        todayStatement = DayStatement(
            date: now,
            isClosed: false,
            hourlyRateSnapshot: setting.hourlyRate
        )
            
        saveTodayStatement()
        savePastStatement()
    }
}
