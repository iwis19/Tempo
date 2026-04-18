//
//  ProfilePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct ProfilePage: View {
    
    // @AppStorage makes it so that these variables are stored on local storage, rather than resetting after each app launch since otherwise it would be stored in memory
    @AppStorage("firstName") private var firstName = ""
    @AppStorage("lastName") private var lastName = ""
    @AppStorage("hourlyRate") private var hourlyRate = 17.95
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = ""
    @AppStorage("reminderMinute") private var reminderMinute = ""
    
    @State private var showHourlyRatePage = false
    
    var body: some View {
        
        PageContainer {
            PageHeader(eyebrow: "Profile", title: "Statement Settings", subtitle: "Set the rate, reminder, and rules Tempo uses for your daily statement.")
            
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
                    
                    // TODO: make text auto fit, or crop, etc
                    VStack (alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(displayName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                                .offset(y: -4)
                            
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

            SettingsCategoryContainer {
                VStack (alignment: .leading) {
                    SettingsSectionTitle(title: "Personal")
                        .padding(.leading, 5) // padding to line up text
                    
                    Button(action: {showHourlyRatePage = true}) {
                        SettingRow(title: "Hourly Rate", icon: "dollarsign.circle.fill", description: "Base value Tempo uses for statement math", details: hourlyRateDisplay)
                    }
                    .buttonStyle(.plain)
                    
                    
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
        .sheet(isPresented: $showHourlyRatePage) {
            ProfileHourlyRatePage(initialHourlyRate: hourlyRate) { newHourlyRate in
                    hourlyRate = newHourlyRate
                }
                .presentationDetents([.large])
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
