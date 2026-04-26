//
//  DashboardPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct DashboardPage: View {
    @AppStorage("firstname") private var firstname = "Jane"
    @AppStorage("hourlyRate") private var hourlyRate = 17.95
    private var statement: DayStatement = DayStatement(date: Date(), isClosed: false)
    private var activities: [Activity] = []


    var body: some View {
        PageContainer{
            PageHeader(
                eyebrow: "Time Account",
                title: "\(greetingText), \(displayFirstName)",
                subtitle: nil
            )
            statementCard
            transactionsSection
            
            
            
            
            
            
        }
    }
    
    private var statementCard: some View {
        MainCard {
            VStack (alignment: .leading, spacing: 10){
                HStack (alignment: .top) {
                    Text("TODAY'S NET")
                        .font(.system(size:12, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .offset(y: 5)
                    
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
    
    
    //TODO: not done
    private var transactionsSection: some View {
        
        VStack (alignment: .leading, spacing: 14) {
            SectionTitle(title: "Today's Transactions")
            
            //if
        }
        
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
        let trimmedName = firstname.trimmingCharacters(in: .whitespacesAndNewlines)
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
            return "Log your first activity to start today's statement."
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
    
    //TODO: not done
//    private var summaryBreakdown: some View {
//        
//        
//        
//    }
    
//    private var todayTransactionItems: [TempoTransactionItem] {
//        statement.activities.map(transactionItem(for:))
//    }
    
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
    
    private func sum(for category: ActivityCategories) -> Double {
        statement.activities.filter{ $0.category == category} .reduce(0) { partialResult, activity in partialResult + amount(for:activity)}
    }
    
    private func amount(for activity: Activity) -> Double {
        guard let category = activity.category, hourlyRate > 0 else {
            return 0
        }
        let hours = Double(activity.durationMinutes) / 60
        return hours * hourlyRate * category.statementMultiplier
    }
}

#Preview {
    DashboardPage()
}
