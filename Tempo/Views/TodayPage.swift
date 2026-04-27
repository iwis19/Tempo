//
//  DashboardPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct TodayPage: View {
    @Environment(UserStore.self) private var userStore
    private var firstName: String {userStore.profile.firstName}
    private var hourlyRate: Double {userStore.setting.hourlyRate}
    private var statement: DayStatement = DayStatement(date: Date(), isClosed: false)
    private var activities: [Activity] = []


    var body: some View {
        PageContainer{
            PageHeader(
                eyebrow: "Today's Statement",
                title: "\(greetingText), \(displayFirstName)",
                subtitle: nil
            )
            statementCard
            transactionsSection
            
            //TODO: summary cards, quick add transaction, remove transaction, picker for category
        }
    }
    
    private var statementCard: some View {
        MainCard {
            VStack (alignment: .leading, spacing: 10){
                HStack (alignment: .top) {
                    Text("TODAY'S NET")
                        .font(.system(size:12, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .offset(y: 8)
                    
                    Spacer()
                    
                    MainCardStatusBadge(text: statusBadgeText)
                
                }

                Text(CurrencyFormatter.string(netTotal, alwaysShowSign: true))
                    .font(.custom("Syne-Regular", size: 46))
                    .foregroundStyle(Color.white)
                
                Text(statementDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.84))
                
                HStack (spacing: 12) {
                    MainCardBox(
                        title: "Entries",
                    description: "\(statement.activities.count)"
                    )
                    MainCardBox(title: "Rate", description: "$\(hourlyRate)/hr")
                }
                
                if let action = actionText {
                    ActionButton(
                        title: action,
                        light: false,
                        action: {}
                    )
                }
            }
        }
    }
    
    private var transactionsSection: some View {
        VStack (alignment: .leading, spacing: 14) {
            SectionTitle(title: "Today's Transactions")
            
            if todayTransactionItems.isEmpty {
                SurfaceCard {
                    Text("Log your first activity to start building today's statement.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.68))
                }
            }
            else {
                VStack (spacing: 12) {
                    ForEach(todayTransactionItems) { item in
                        LedgerRow(item: item)
                    }
                }
            }
        }
    }
    
    private var todayTransactionItems: [TransactionItem] {
        statement.activities.map(item(for:))
    }
    
    private var greetingText: String {
        // takes the hour from the user's local time
        let hour = Calendar.current.component(.hour, from: Date())
        
        // this is the switch statement syntax in swift
        switch hour {
            case 0..<12: return "Good morning"
            case 12..<18: return "Good afternoon"
            case 18...: return "Good evening"
            default: return "Hello"
        }
    }

    private var displayFirstName: String {
        let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Jane" : trimmedName
    }
    
    private var statusBadgeText: String {
        if statement.isClosed {
            return "Statement Closed"
        }
        
        return "Statement Open"
    }
    
    private var statementDescription: String {
        if statement.isClosed {
            return "Today's statement is closed and ready in the ledger."
        }
        if hourlyRate <= 0 {
            return "Set your hourly rate in profile to turn time into statement value."
        }
        if statement.activities.isEmpty {
            return "Log your first activity to start building today's statement."
        }
        if netTotal > 0 {
            return "Your daily statement is currently in profit."
        }
        if netTotal < 0 {
            return "Your daily statement is currently negative."
        }
        return "Your daily statement is currently balanced."
    }
    
    private var actionText: String? {
        if statement.isClosed {
            return nil
        }
        if statement.activities.isEmpty {
            return "Start Checkup"
        }
        return "Close Statement"
    }
    
    private var earnedTotal: Double {
        sum(for: .earned)
    }
    
    private var requiredTotal: Double {
        sum(for: .required)
    }
    
    private var spentTotal: Double {
        sum(for: .spent)
    }
    
    private var netTotal: Double {
        earnedTotal + spentTotal + requiredTotal
    }
    
    private func durationDisplay(for minutes: Int) -> String{
        let hours = minutes / 60
        let remainder = minutes % 60
        
        if hours > 0 && remainder > 0{
            return "\(hours)h \(remainder)m"
        }
        if hours > 0{
            return "\(hours)h"
        }
        return "\(remainder)m"
    }
    
    private func sum(for category: ActivityCategories) -> Double {
        statement.activities.filter{ $0.category == category} .reduce(0) { partialResult, activity in partialResult + amount(for:activity)}
    }
    
    private func amount(for activity: Activity) -> Double {
        guard hourlyRate > 0 else {
            return 0
        }
        let hours = Double(activity.durationMinutes) / 60
        return hours * hourlyRate * activity.category.statementMultiplier
    }
    
    private func item(for activity: Activity) -> TransactionItem {
        let categoryText = activity.category.title
        
        let tone: Flowtone = {
            switch activity.category {
            case .earned: return .positive
            case .required, .spent: return .negative
            }
        }()
        
        return TransactionItem(
            id: activity.id,
            title: activity.name,
            duration: durationDisplay(for: activity.durationMinutes),
            category: categoryText,
            amount: CurrencyFormatter.string(amount(for: activity), alwaysShowSign: true),
            tone: tone
        )
    }
}

#Preview {
    TodayPage()
        .environment(UserStore())
}
