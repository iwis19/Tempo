//
//  DashboardPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-27.
//

import SwiftUI
import Charts

struct DashboardPage: View {
    @Environment(UserStore.self) private var userStore

    private var hourlyRate: Double { userStore.setting.hourlyRate }
    private var todayStatement: DayStatement { userStore.todayStatement }
    private var pastStatements: [DayStatement] { userStore.pastStatement }
    
    @State private var selectedDay: String?
    
    private var positive: Bool { totalCash >= 0 }

    var body: some View {
        PageContainer {
            PageHeader(
                eyebrow: "Dashboard",
                title: "\(greetingText), \(displayFirstName)",
                subtitle: nil
            )
            balanceCard
            summaryCardRow
            trendSection
        }
    }

    private var balanceCard: some View {
        MainCard (positive: positive) {
            HStack(alignment: .top) {
                Text("TOTAL CASH")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .offset(y: 8)

                Spacer()

                MainCardStatusBadge(text: statusBadgeText, positive: positive)
            }

            Text(CurrencyFormatter.string(totalCash))
                .font(.custom("Syne-Regular", size: 46))
                .foregroundStyle(Color.white)

            Text(balanceDescription)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.84))

            HStack(spacing: 12) {
                MainCardBox(
                    title: "Logged Days",
                    description: "\(statementsWithEntries.count)"
                )
                MainCardBox(
                    title: "Avg Logged Day",
                    description: allTimeAverageDayDisplay
                )
            }
        }
    }

    private var summaryCardRow: some View {
        HStack(alignment: .top, spacing: 8) {
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
    

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            SurfaceCard {
                SectionTitle(title: "Your Last 7 Days")
                
                Text("Your week in a graph")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.85))
                    .padding(.bottom, 4)
                
                if !hasGraphData {
                    Text("Close your first statement to see your weekly trend.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("tempoInk").opacity(0.65))
                            .padding(.bottom, 8)
                }
                else {
                    Chart(graphData) { day in
                        BarMark(
                            x: .value("Day", day.dayLabel),
                            y: .value("Net", day.net),
                            width: 25
                        )
                        .cornerRadius(8)
                        .foregroundStyle(day.net >= 0 ? positiveGradient : negativeGradient)
                        .annotation(
                            position: day.net >= 0 ? .top : .bottom,
                            overflowResolution:
                                .init(x: .fit, y:.disabled) // blocks the numbers from overflowing and messing up bar shape
                        ) {
                            if selectedDay == day.dayLabel {
                                let netDisplay = String(format: "%.2f", abs(day.net))
                                
                                Text(day.net >= 0 ? "+$\(netDisplay)" : "-$\(netDisplay)")
                                    .foregroundStyle(Color("tempoInk"))
                                    .font(.system(size: 17))
                                    .padding(6)
                                    .background(Color(.white))
                                    .clipShape(RoundedRectangle(cornerRadius:8))
                            }
                        }
                        
                    }
                    .chartXSelection(value: $selectedDay)
                    .frame(height: 200)
                    .padding(.top, 6)
                    .padding(.horizontal, 5)
                    .chartXScale(
                        range: .plotDimension(
                            startPadding: 6,
                            endPadding: 6
                        )
                    )
                    // manually handling what x axis elements to display
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                        }
                    }
                    .padding(.bottom, 20)
                    //.chartYAxis(.hidden)
                }
                
                Text("Your week by the numbers")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.85))
                    .padding(.bottom, 7)

                PreviewRow(
                    title: "Days With Logs",
                    value: "\(sevenDayStatements.count)",
                    tint: Color("tempoDeepGreen"),
                    background: sevenDayStatements.isEmpty ? Color("tempoNeutralCard") : Color("tempoShell")
                )

                PreviewRow(
                    title: "7D Net",
                    value: sevenDayNetDisplay,
                    tint: sevenDayNetTint,
                    background: sevenDayNetBackground
                )

                PreviewRow(
                    title: "7D Avg Day",
                    value: averageClosedDayDisplay,
                    tint: averageClosedDayTint,
                    background: averageClosedDayBackground
                )

                PreviewRow(
                    title: "7D Best Day",
                    value: bestDayDisplay,
                    tint: bestDayTint,
                    background: bestDayBackground
                )
            }
        }
    }
    
    private var hasGraphData: Bool {
        closedStatements
            .filter { statement in
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let cutoff = calendar.date(byAdding: .day, value: -6, to: today) ?? today
                let statementDay = calendar.startOfDay(for: statement.date)

                return statementDay >= cutoff && statementDay <= today
            }
            .contains { !$0.activities.isEmpty }
    }

    
    private struct GraphData: Identifiable {
        var day: Date
        var dayLabel: String
        var net: Double
        
        var id: Date { day }
    }
    
    private var graphData: [GraphData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cutoff = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        return closedStatements
            .filter { statement in
                let statementDay = calendar.startOfDay(for: statement.date)
                return statementDay >= cutoff && statementDay <= today
            }
            .sorted { $0.date < $1.date }
            .map { statement in
                let day = calendar.startOfDay(for: statement.date)
                
                return GraphData(
                    day: day,
                    dayLabel: weekdayText(for: day),
                    net: net(for: statement)
                )
            }
    }
    
    private func weekdayText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }


    private var displayFirstName: String {
        let trimmedName = userStore.profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Jane" : trimmedName
    }

    private var statementsWithEntries: [DayStatement] {
        let combined = pastStatements + activeTodayStatement
        return combined
            .filter { !$0.activities.isEmpty }
            .sorted { $0.date > $1.date }
    }

    private var closedStatements: [DayStatement] {
        let combined = pastStatements + closedTodayStatement
        return combined
            .sorted { $0.date > $1.date }
    }

    private var totalCash: Double {
        historyNetTotal + todayNetTotal
    }

    private var todayNetTotal: Double {
        net(for: todayStatement)
    }

    private var historyNetTotal: Double {
        pastStatements.reduce(0) { partialResult, statement in
            partialResult + statement.netTotal
        }
    }

    private var earnedTotal: Double {
        total(for: .earned)
    }

    private var requiredTotal: Double {
        total(for: .required)
    }

    private var spentTotal: Double {
        total(for: .spent)
    }

    private var sevenDayStatements: [DayStatement] {
        let cutoff = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        )

        return statementsWithEntries.filter { statement in
            statement.date >= cutoff
        }
    }
    
    private var sevenDayNet: Double {
        sevenDayStatements.reduce(0) { partialResult, statement in
            partialResult + net(for: statement)
        }
    }

    private var averageClosedDayNet: Double {
        guard !sevenDayStatements.isEmpty else {
            return 0
        }

        let total = sevenDayStatements.reduce(0) { partialResult, statement in
            partialResult + net(for: statement)
        }

        return total / Double(sevenDayStatements.count)
    }

    private var bestDayStatement: DayStatement? {
        sevenDayStatements.max { left, right in
            net(for: left) < net(for: right)
        }
    }

    private var statusBadgeText: String {
        if statementsWithEntries.isEmpty {
            return "No History"
        }

        if hourlyRate <= 0 {
            return "Rate Needed"
        }

        if todayStatement.activities.isEmpty {
            return "Trend Ready"
        }

        if todayNetTotal > 0 {
            return "Up Today"
        }

        if todayNetTotal < 0 {
            return "Down Today"
        }

        return "Flat Today"
    }

    private var balanceDescription: String {
        if statementsWithEntries.isEmpty {
            return "Close your first statement to start building a running total and a real history trend."
        }

        if hourlyRate <= 0 {
            return "Set your hourly rate in Profile so Tempo can translate your statement history into value."
        }

        if todayStatement.activities.isEmpty {
            return "You've closed \(closedStatements.count) statements so far. Log today's activity to keep the trend moving."
        }

        if todayNetTotal > 0 {
            return "Today's statement is adding \(CurrencyFormatter.string(abs(todayNetTotal), shorten: true)) of positive value."
        }

        if todayNetTotal < 0 {
            return "Today's statement is pulling \(CurrencyFormatter.string(abs(todayNetTotal), shorten: true)) out of the running total. If you closed now, it would fall toward \(CurrencyFormatter.string(totalCash, shorten: true))."
        }

        return "Today's statement is balanced right now, so your running total is staying flat."
    }

    private var sevenDayNetDisplay: String {
        if sevenDayStatements.isEmpty {
            return "No days"
        }

        guard hourlyRate > 0 else {
            return "Set rate"
        }

        return CurrencyFormatter.string(sevenDayNet, shorten: true, alwaysShowSign: true)
    }

    private var averageClosedDayDisplay: String {
        if sevenDayStatements.isEmpty {
            return "No days"
        }

        guard hourlyRate > 0 else {
            return "Set rate"
        }

        return CurrencyFormatter.string(averageClosedDayNet, alwaysShowSign: true)
    }

    private var bestDayDisplay: String {
        guard let bestDayStatement else {
            return "No days"
        }

        guard hourlyRate > 0 else {
            return statementDateText(for: bestDayStatement.date)
        }

        return CurrencyFormatter.string(net(for: bestDayStatement), alwaysShowSign: true)
    }
    
    private var bestDayBackground: Color {
        guard let bestDayStatement else {
            return Color("tempoNeutralCard")
        }
        
        return net(for: bestDayStatement) >= 0 ? Color("tempoShell") : Color("tempoLossWash")
    }
    
    private var averageClosedDayBackground: Color {
        if sevenDayStatements.isEmpty {
            return Color("tempoNeutralCard")
        }

        guard hourlyRate > 0 else {
            return Color("tempoNeutralCard")
        }

        return averageClosedDayNet >= 0 ? Color("tempoShell") : Color("tempoLossWash")
    }
    
    private var sevenDayNetBackground: Color {
        if sevenDayStatements.isEmpty {
            return Color("tempoNeutralCard")
        }

        guard hourlyRate > 0 else {
            return Color("tempoNeutralCard")
        }

        return sevenDayNet >= 0 ? Color("tempoShell") : Color("tempoLossWash")
    }

    private var sevenDayNetTint: Color {
        if hourlyRate <= 0 {
            return Color("tempoLossRed")
        }

        if sevenDayStatements.isEmpty {
            return Color("tempoInk")
        }

        return tone(for: sevenDayNet).tint
    }

    private var averageClosedDayTint: Color {
        if hourlyRate <= 0 {
            return Color("tempoLossRed")
        }

        if sevenDayStatements.isEmpty {
            return Color("tempoInk")
        }

        return tone(for: averageClosedDayNet).tint
    }

    private var bestDayTint: Color {
        guard let bestDayStatement else {
            return Color("tempoInk")
        }

        guard hourlyRate > 0 else {
            return Color("tempoDeepGreen")
        }

        return tone(for: net(for: bestDayStatement)).tint
    }
    
    private var allTimeAverageDayNet: Double {
        guard !statementsWithEntries.isEmpty else {
            return 0
        }

        let total = statementsWithEntries.reduce(0) { partialResult, statement in
            partialResult + net(for: statement)
        }

        return total / Double(statementsWithEntries.count)
    }

    private var allTimeAverageDayDisplay: String {
        if statementsWithEntries.isEmpty {
            return "No days"
        }

        guard hourlyRate > 0 else {
            return "Set rate"
        }

        return CurrencyFormatter.string(allTimeAverageDayNet, shorten: true, alwaysShowSign: true)
    }

    private var activeTodayStatement: [DayStatement] {
        if todayStatement.activities.isEmpty && !todayStatement.isClosed {
            return []
        }

        return [todayStatement]
    }

    private var closedTodayStatement: [DayStatement] {
        if todayStatement.isClosed && !todayStatement.activities.isEmpty {
            return [todayStatement]
        }

        return []
    }

    private func total(for category: ActivityCategory) -> Double {
        statementsWithEntries.reduce(0) { partialResult, statement in
            partialResult + statementTotal(for: category, in: statement)
        }
    }

    private func statementTotal(for category: ActivityCategory, in statement: DayStatement) -> Double {
        if statement.isClosed {
            switch category {
            case .earned:
                return statement.earnedTotal
            case .required:
                return statement.requiredTotal
            case .spent:
                return statement.spentTotal
            }
        }
        
        return StatementCalculator.total(for: category, in: statement, hourlyRate: hourlyRate)
    }

    private func net(for statement: DayStatement) -> Double {
        statement.isClosed ? statement.netTotal : StatementCalculator.netTotal(for: statement, hourlyRate: hourlyRate)
    }

    private func tone(for amount: Double) -> Flowtone {
        if amount > 0 {
            return .positive
        }

        if amount < 0 {
            return .negative
        }

        return .neutral
    }
    private func statementDateText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    let userStore = UserStore()
    userStore.todayStatement = DemoData.todayStatement
    userStore.pastStatement = DemoData.pastStatements
    userStore.setting.hourlyRate = 40.23

    return DashboardPage()
        .environment(userStore)
}
