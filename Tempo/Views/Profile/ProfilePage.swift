//
//  ProfilePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct ProfilePage: View {

    @Environment(UserStore.self) private var userStore
    private var firstName: String {userStore.profile.firstName}
    private var lastName: String {userStore.profile.lastName}
    private var hourlyRate: Double {userStore.setting.hourlyRate}
    private var reminderEnabled: Bool {userStore.setting.reminderEnabled}
    private var reminderHour: Int {userStore.setting.reminderHour}
    private var reminderMinute: Int {userStore.setting.reminderMinute}
    
    @State private var showFeedbackPage = false
    @State private var showHourlyRatePage = false
    @State private var showDailyReminderPage = false
    @State private var showNamePage = false
    @State private var showTimeCategoryPage = false
    @State private var showStatementGuidePage = false
    
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
                    MainCardBox(
                        title: "Hourly Rate",
                        description: hourlyRateDisplay
                    )
                    MainCardBox(
                        title: "Reminder",
                        description: reminderDisplay
                    )
                }
            }

            SurfaceCard {
                VStack (alignment: .leading) {
                    SectionTitle(title: "Personal")
                        .padding(.leading, 5) // padding to line up text
                    
                    Button (action: {showNamePage = true}) {
                        SettingRow(
                            title: "Name",
                            icon: "person.crop.circle.fill",
                            description: "How your account appears across Tempo",
                            details: displayName
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {showHourlyRatePage = true}) {
                        SettingRow(
                            title: "Hourly Rate",
                            icon: "dollarsign.circle.fill",
                            description: "Base value Tempo uses for statement math",
                            details: hourlyRateDisplay
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {showDailyReminderPage = true}){
                        SettingRow(
                            title: "Daily Reminder",
                            icon: "bell.badge.fill",
                            description: "Checkup prompts and close-of-day nudges", 
                            details: reminderDisplay
                        )
                    }
                    .buttonStyle(.plain)
                
                }
            }
            
            SurfaceCard {
                VStack (alignment: .leading){
                    SectionTitle(title: "Learn Tempo")
                    
                    Button (action: {showTimeCategoryPage = true}) {
                        SettingRow(
                            title: "Time Categories",
                            icon: "square.grid.2x2.fill",
                            description: "Learn what belongs in Earned, Required, and Spent",
                            details: "Open Guide"
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { showStatementGuidePage = true }) {
                        SettingRow(
                            title: "How Statements Work",
                            icon: "doc.text.magnifyingglass",
                            description: "See how Tempo turns your day into a statement",
                            details: "Open Guide"
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { showFeedbackPage = true }) {
                        SettingRow(
                            title: "Feedback",
                            icon: "heart.text.square.fill",
                            description: "Share friction points, bugs, or future ideas",
                            details: "Share"
                        )
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
             
             Learn Tempo
             - Time categories, what belongs in what
             - How daily statements work
             - Feedback
             */
        }
        .sheet(isPresented: $showHourlyRatePage) {
            ProfileHourlyRatePage(initialHourlyRate: hourlyRate) { newHourlyRate in
                userStore.setting.hourlyRate = newHourlyRate
                userStore.saveSetting()
                }
                .presentationDetents([.large])
           }
        .sheet(isPresented: $showNamePage) {
            ProfileNamePage(
                initialFirstName: firstName,
                initialLastName: lastName
            ) { newFirstName, newLastName in
                userStore.profile.firstName = newFirstName
                userStore.profile.lastName = newLastName
                userStore.saveProfile()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showDailyReminderPage) {
            ProfileDailyReminderPage (
                initialReminderEnabled: reminderEnabled,
                initialReminderHour: reminderHour,
                initialReminderMinute: reminderMinute
            ) { newReminderEnabled, newReminderHour, newReminderMinute in
                userStore.setting.reminderEnabled = newReminderEnabled
                userStore.setting.reminderHour = newReminderHour
                userStore.setting.reminderMinute = newReminderMinute
                userStore.saveSetting()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showFeedbackPage) {
            ProfileFeedbackPage()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showTimeCategoryPage) {
            ProfileTimeCategoriesPage()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showStatementGuidePage) {
            ProfileDailyStatementGuidePage()
                .presentationDetents([.large])
        }
    }
    
    private var displayInitial: String {
        
        // string.first safely retrieves the first character as an OPTIONAL, if it does exist, we map it into a string, if it doesnt, we return an empty string
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        let initial = firstInitial + lastInitial
        return initial.isEmpty ? "JD" : initial
    }
    
    private var displayName: String {
        
        // trimmingCharacters removes useless leading or trailing whitespaces
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? "Jane Doe" : fullName
    }

    private var profileStatusText: String {
        if hourlyRate <= 0 {
            return "Add your hourly rate to start valuing time."
        }
        if reminderEnabled {
            return "Daily statement setup is complete."
        }
        return "No daily reminder set."
    }

    private var statusBadgeText: String {
        if hourlyRate <= 0 {
            return "Needs Setup"
        }
        return reminderEnabled ? "Ready" : "Reminder Off"
    }

    private var hourlyRateDisplay: String {
        
        if hourlyRate <= 0 {
            return "Not set"
        }
        return CurrencyFormatter.string(hourlyRate)
    }

    private var reminderDisplay: String {
        if !reminderEnabled {
            return "Off"
        }
        return TimeFormatter.string(hour: reminderHour, minute: reminderMinute)
    }

}

#Preview {
    ProfilePage()
        .environment(UserStore())
}
