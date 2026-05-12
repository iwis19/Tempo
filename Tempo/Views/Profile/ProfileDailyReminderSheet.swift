//
//  ProfileDailyReminderPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-18.
//

import SwiftUI

struct ProfileDailyReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationHandler.self) private var notificationHandler
    
    let onSave: (Bool, Int, Int) -> Void
    
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    
    init(
        initialReminderEnabled: Bool = true,
        initialReminderHour: Int = 20,
        initialReminderMinute: Int = 0,
        onSave: @escaping (Bool, Int, Int) -> Void = {_, _, _ in}
    ) {
        self.onSave = onSave
        _reminderEnabled = State(initialValue: initialReminderEnabled)
        _reminderTime = State(initialValue: Self.date(hour: initialReminderHour, minute: initialReminderMinute))
    }
    
    var body: some View{
        ZStack{
            PageBackground()
            
            ScrollView (showsIndicators: false) {
                VStack (alignment: .leading, spacing: 15) {
                    VStack (spacing: 14){
                        
                        DragIndicator()
                        
                        PageHeader(
                            eyebrow: "Daily Reminder",
                            title: "Set your close-of-day prompt",
                            subtitle: "Choose whether Tempo nudges you and when that reminder should arrive.")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                    
                    
                    SurfaceCard {
                        Text("Reminder Settings")
                            .font(.system(size:12, weight: .bold))
                            .foregroundStyle(Color("tempoInk").opacity(0.52))
                        
                        Toggle(isOn: $reminderEnabled){
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Reminder")
                                    .font(.system(size:16, weight: .semibold))
                                    .foregroundStyle(Color("tempoInk"))
                            }
                        }
                        .tint(Color("tempoLeaf"))
                        
                        if reminderEnabled {
                            Divider()
                                .overlay(Color("tempoLeaf").opacity(0.12))
                            
                            VStack (alignment:.leading, spacing: 10){
                                Text("Reminder Time")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("tempoInk"))
                                
                                DatePicker(
                                    "Reminder Time",
                                    selection: $reminderTime,
                                    displayedComponents: . hourAndMinute
                                )
                                .datePickerStyle(.wheel)
                                .tint(Color("tempoLeaf"))
                                .frame(maxWidth: .infinity)
                                .clipped()
                            }
                        }
                    }
                    
                    SurfaceCard{
                        SectionTitle(title:"Preview")
                        
                        VStack(spacing: 12){
                            PreviewRow(
                                title: "Reminder Status",
                                value: reminderEnabled ? "On" : "Off",
                                tint: reminderEnabled ? Color("tempoLeaf") : Color("tempoInk").opacity(0.58)
                            )
                            PreviewRow(
                                title: "Notification Time",
                                value: reminderDisplay,
                                tint: Color("tempoDeepGreen")
                            )
                        }
                    }
                    
                    HStack (spacing: 12){
                        ActionButton(
                            title: "Cancel",
                            action: dismiss.callAsFunction
                        )
                        ActionButton(
                            title: "Save Reminder",
                            action: saveReminder
                        )
                    }
                    
                    Spacer()
                    
                    VStack (alignment: .center, spacing: 10){
                        Text("Not working?")
                            .foregroundStyle(.gray)
                            .italic()
                        
                        Button("Request permissions") {
                            notificationHandler.askPermission()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
    
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
        }
    }
    
    private var reminderDisplay: String {
        guard reminderEnabled else{
            return "Off"
        }
        return Self.formatted(reminderTime)
    }
    
    private func saveReminder() {
        // this line essentially extracts the hour and minute component of the reminderTime, which is type Date. components has type DateComponents
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let hour = components.hour ?? 20  // default 20
        let minute = components.minute ?? 0  //default 00
        
        onSave(reminderEnabled, hour, minute)
        dismiss()
    }
    
    // takes in hour and minute to return a Date value (today's exact hour and minute time)
    private static func date(hour: Int, minute: Int) -> Date{
        
        // takes year, month, day DateComponent from the CURRENT day
        var components = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        
        // builds the rest of the components
        components.hour = hour
        components.minute = minute
        
        // build the actual reminder time of the day
        return Calendar.current.date(from:components) ?? Date()
    }
    
    // turns a Date value into a String value (hour:minute AM/PM)
    private static func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        // date format: h = hour, mm = minute, a = AM/PM marker
        formatter.dateFormat = "h:mm a"
        
        // return it as a string in that specific format just set
        return formatter.string(from: date)
    }
}


#Preview {
    ProfileDailyReminderSheet()
        .environment(NotificationHandler())
}
