//
//  TodayPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct TodayPage: View {
    
    // using environment instead of creating a new UserStore() object because this is environment (app wide), rather than creating a new dataset/base for every single different page there is on this app
    @Environment(UserStore.self) private var userStore
    
    private var firstName: String { userStore.profile.firstName }
    private var hourlyRate: Double { userStore.setting.hourlyRate }
    private var statement: DayStatement { userStore.todayStatement }
    
    @State private var showTodayStatementSheet: Bool = false
    
    private var positive: Bool { netTotal >= 0 }

    var body: some View {
        PageContainer{
            PageHeader(
                eyebrow: "Today",
                title: "\(TimeFormatter.greetingText(for: Date())), \(displayFirstName)",
                subtitle: nil
            )
            statementCard
            summaryCardRow
            transactionsSection
        }
        .sheet(isPresented: $showTodayStatementSheet) {
            TodayStatementSheet(
                initialStatement: userStore.todayStatement
            ) { activities in
                userStore.todayStatement.activities = activities
                userStore.saveTodayStatement()
            }
                .presentationDetents([.large])
        }
        
    }
    
    private var statementCard: some View {
        MainCard (positive: positive){
            HStack (alignment: .top) {
                Text("TODAY'S NET")
                    .font(.system(size:12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .offset(y: 8)
                
                Spacer()
                
                MainCardStatusBadge(text: statusBadgeText, positive: positive)
            
            }

            Text(CurrencyFormatter.string(netTotal, alwaysShowSign: true))
                .font(.custom("Syne-Regular", size: 46))
                .foregroundStyle(Color.white)
            
            Text(statementCardSubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.84))
                .padding(.bottom, 5)
            
            HStack (spacing: 12) {
                MainCardBox(
                    title: "Entries",
                    description: "\(statement.activities.count)"
                )
                MainCardBox(title: "Rate", description: "\(CurrencyFormatter.string(statementHourlyRate))/hr")
            }
            
            HStack (spacing: 12) {
                ActionButton(
                    title: actionText,
                    light: positive ? false : true,
                    action: {
                        // is statement is already closed, sheet cannot be opened
                        showTodayStatementSheet = true
                    }
                )
                .disabled(statement.isClosed)
                
                ActionButton(
                    title: "Close Statement",
                    light: positive ? false : true,
                    action: closeStatement
                )
                .disabled(statement.isClosed)
            }
 
        }
    }
    
    private func closeStatement() {
        userStore.todayStatement = StatementCalculator.snapshot(
            for: userStore.todayStatement,
            hourlyRate: hourlyRate,
            isClosed: true
        )
        userStore.saveTodayStatement()
    }
    
    private var transactionsSection: some View {
        VStack (alignment: .leading, spacing: 14) {
            SectionTitle(
                title: "Today's Transactions",
                subtitle: nil
            )
            
            if statement.activities.isEmpty {
                SurfaceCard {
                    Text("Log your first activity to start building today's statement.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("tempoInk").opacity(0.68))
                }
            }
            else {
                VStack (spacing: 12) {
                    ForEach(statement.activities) { activity in
                        SurfaceCard{
                            LedgerRow(activity: activity, amount: ActivityCalculator.amount(for: activity, hourlyRate: statementHourlyRate))
                        }
                    }
                }
                
            }
        }
    }
    
    private var summaryCardRow: some View {
        HStack (alignment: .top, spacing: 8) {
            summaryCard(
                title: ActivityCategory.earned.title,
                value: CurrencyFormatter.string(earnedTotal, shorten: true, alwaysShowSign: true),
                subtitle: "Focused",
                tint: Flowtone.positive.tint,
                background: Flowtone.positive.background,
                gain: true
            )
            summaryCard(
                title: ActivityCategory.required.title,
                value: CurrencyFormatter.string(requiredTotal, shorten: true, alwaysShowSign: true),
                subtitle: "Basics",
                tint: Flowtone.neutral.tint,
                background: Flowtone.neutral.background,
                gain: false
            )
            summaryCard(
                title: ActivityCategory.spent.title,
                value: CurrencyFormatter.string(spentTotal, shorten: true, alwaysShowSign: true),
                subtitle: "Drift",
                tint: Flowtone.negative.tint,
                background: Flowtone.negative.background,
                gain: false
            )
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
    
    private var statementCardSubtitle: String {
        if statement.isClosed {
            return "Today's statement is closed."
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
    
    private var actionText: String {
        if statement.isClosed {
            return "Closed"
        }
        if statement.activities.isEmpty {
            return "Start Checkup"
        }
        return "Continue"
    }
    
    private var earnedTotal: Double {
        statement.isClosed ? statement.earnedTotal : sum(for: .earned)
    }
    
    private var requiredTotal: Double {
        statement.isClosed ? statement.requiredTotal : sum(for: .required)
    }
    
    private var spentTotal: Double {
        statement.isClosed ? statement.spentTotal : sum(for: .spent)
    }
    
    private var netTotal: Double {
        statement.isClosed ? statement.netTotal : earnedTotal + spentTotal + requiredTotal
    }
    
    private func sum(for category: ActivityCategory) -> Double {
        StatementCalculator.total(for: category, in: statement, hourlyRate: hourlyRate)
    }
    
    private var statementHourlyRate: Double {
        statement.isClosed ? statement.hourlyRateSnapshot : hourlyRate
    }
    
}

#Preview {
    let userStore = UserStore()
    userStore.todayStatement = DemoData.todayStatement
    userStore.setting.hourlyRate = 40.23
    
    return TodayPage()
        .environment(userStore)
}
