//
//  TodayStatementSheet.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-05-07.
//

import SwiftUI

struct TodayStatementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserStore.self) private var userStore
    
    let onSave: ([Activity]) -> Void
    let initialStatement: DayStatement
    
    @State private var activities: [Activity]
    @State private var draftActivityTitle: String = ""
    @State private var draftActivityTime: String = "" // will do type conv later
    @State private var draftActivityChoice: ActivityCategory = .earned
    private var hourlyRate: Double { userStore.setting.hourlyRate }
    
    init(
        initialStatement: DayStatement,
        onSave : @escaping ([Activity]) -> Void = {_ in}
    ) {
        self.initialStatement = initialStatement
        self.onSave = onSave
        
        // @State adds behavior on top of a regular value stored in swift with var. hence, this is a wrapper value since it must be wrapped to have extra behavior on top of the regular type that it was given. _varname helps work with these wrapped values, and tells swift im working with the value under the wrapper storage. _activities is wrapper object im working with, activities is the nice one i see.
        _activities = State(initialValue: initialStatement.activities)
    }
    
    var body: some View {
        ZStack {
            PageBackground()
            
            ScrollView (showsIndicators: false) {
                VStack (alignment: .leading, spacing: 15){
                    VStack (spacing: 14){
                        DragIndicator()
                        
                        PageHeader(
                            eyebrow: "Your Day",
                            title: "Today's Statement",
                            subtitle: "Log what happened, classify each block, and close tonight's statement."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                    
                    activityReview
                    quickAddSection
                    
                    HStack (spacing: 12) {
                        ActionButton(
                            title: "Cancel",
                            action: dismiss.callAsFunction
                        )
                        ActionButton(
                            title: "Save Activities",
                            action: saveActivities
                        )
                    }
                    
                }
                
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 34)
        }
    }
    
    private var activityReview: some View {
        VStack (alignment: .leading, spacing: 14) {
            SectionTitle(title: reviewText)
            
            if activities.isEmpty{
                SurfaceCard {
                    Text("No activities yet. Use Quick Add below to build today's statement.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.68))
                }
            } else {
                VStack(spacing: 12) {
                    ForEach($activities) { $activity in
                        ActivityRow(
                            activity: $activity,
                            amount: ActivityCalculator.amount(for: activity, hourlyRate: hourlyRate),
                            onDelete: {
                                deleteActivity(id: activity.id)
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var reviewText: String {
        if activities.count > 1 {
            "Review Today's Activities"
        } else {
            "Review Today's Activity"
        }
    }
    
    private struct ActivityRow: View {
        @Binding var activity: Activity
        let amount: Double
        let onDelete: () -> Void

        var body: some View {
            SurfaceCard {
                LedgerRow(activity: activity, amount: amount)
                
                HStack(spacing: 10) {
                    ForEach(ActivityCategory.allCases) { category in
                        Button(action: {
                            activity.category = category
                        }) {
                            Text(category.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(activity.category == category ? .white : category.tint)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(activity.category == category ? category.tint : category.background)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color("tempoLossRed"))
                            .padding(10)
                            .background(Color("tempoLossWash").opacity(0.92))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func deleteActivity(id: UUID) {
        activities.removeAll { $0.id == id }
    }
    
    private var quickAddSection: some View {
        
        SurfaceCard {
            SectionTitle(title: "Quick Add")
            
            VStack (alignment: .leading, spacing: 14){
                TextField("Activity title", text: $draftActivityTitle)
                    .font(.system(size:16, weight: .medium))
                    .foregroundStyle(Color("tempoInk"))
                    .padding(14)
                    .background(Color("tempoShell").opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius:18, style: .continuous))
                
                
                HStack (spacing: 12) {
                    TextField("30", text: $draftActivityTime)
                        .keyboardType(.numberPad)
                        .font(.system(size:16, weight: .medium))
                        .foregroundStyle(Color("tempoInk"))
                        .padding(14)
                        .background(Color("tempoShell"))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    Text("minutes")
                        .font(.system(size:15, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.58))
                    
                }
                
                HStack (spacing: 10) {
                    ForEach(ActivityCategory.allCases) { category in
                        Button(action: {draftActivityChoice = category }) {
                            Text(category.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(draftActivityChoice == category ? .white : category.tint)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(draftActivityChoice == category ? category.tint : category.background)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: addDraftEntry) {
                        Text("Add")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color("tempoDeepGreen"))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .opacity(canAddDraft ? 1 : 0.55)
                    .disabled(!canAddDraft)
                }
            }
        }
    }
    
    private var canAddDraft: Bool {
        !draftActivityTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (Int(draftActivityTime) ?? 0) > 0
    }
    
    private func addDraftEntry() {
        guard canAddDraft, let minutes = Int(draftActivityTime), minutes > 0 else {return}
        activities.append(
            Activity(
                name: draftActivityTitle,
                length: minutes,
                category: draftActivityChoice
            )
        )
        
        draftActivityTime = ""
        draftActivityTitle = ""
        draftActivityChoice = .earned
        
    }
    
    private func saveActivities() {
        onSave(activities)
        dismiss()
    }
}


#Preview {
    let userStore = UserStore()
    userStore.todayStatement = DemoData.todayStatement
    
    // swift wanted an explicit return for the view expression since it is no longer the only line in preview section
    return TodayStatementSheet(
        initialStatement: userStore.todayStatement
    )
        .environment(userStore)
}
