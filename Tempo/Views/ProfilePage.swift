//
//  ProfilePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct ProfilePage: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var hourlyRate = ""   // here, hourlyRate is a string, but we will later convert into a Double, just like reminderHour and reminderMinute
    @State private var reminderEnabled = false
    @State private var reminderHour = ""
    @State private var reminderMinute = ""
    
    var body: some View {
        
        PageContainer {
            Header(eyebrow: "Profile", title: "Statement Settings", subtitle: "Set the rate, reminder, and rules Tempo uses for your daily statement.")
            
            MainCard {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.14))
                            .frame(width: 68, height: 68)

                        Text(displayInitial)
                            .font(.custom("Syne-Regular", size: 28))
                            .foregroundStyle(.white)
                    }
                    
                    VStack (alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(displayName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            MainCardStatusBadge(text: statusBadgeText)
                                .offset(y: -4)
                        }
                        
                        Text(profileStatusText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }

                HStack(spacing: 12) {
                    MainCardBox(title: "Hourly Rate", description: hourlyRateDisplay)
                    MainCardBox(title: "Reminder", description: reminderDisplay)
                }
            }

            
            
            /*
             TODO: sections be added are:
             Personal
             - First and Last name
             - Hourly rate
             - Daily reminder
             - maybe more
             
             App
             - Appearance
             - Feedback
             
             Learn Tempo
             - Time categories, what belongs in what
             - How daily statements work
             */
        }
    }
    
    private var displayInitial: String {
        
        // string.first safely retrieves the first character as an OPTIONAL, if it does exist, we map it into a string, if it doesnt, we return an empty string
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        let initial = firstInitial + lastInitial
        return initial.isEmpty ? "U" : initial
    }
    
    private var displayName: String {
        
        // trimmingCharacters removes useless leading or trailing whitespaces
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? "User" : fullName
    }

    private var profileStatusText: String {
        if hourlyRateValue == nil || hourlyRateValue == 0 {
            return "Add your hourly rate to start valuing time."
        }
        if reminderEnabled {
            return "Daily statement setup is complete."
        }
        return "No daily reminder set."
    }

    private var statusBadgeText: String {
        if hourlyRateValue == nil || hourlyRateValue == 0 {
            return "Needs Setup"
        }
        return reminderEnabled ? "Ready" : "Reminder Off"
    }

    private var hourlyRateDisplay: String {
        
        // guard is also an if condition, besides it forces an early exit if the condition is not true
        guard let hourlyRateValue, hourlyRateValue > 0 else {
            return "Not set"
        }
        return hourlyRateValue.formatted(.currency(code: "USD").precision(.fractionLength(0...2)))
    }

    private var reminderDisplay: String {
        reminderEnabled ? "On" : "Off"
    }

    private var hourlyRateValue: Double? {
        Double(hourlyRate)
    }
    
}

#Preview {
    ProfilePage()
}
