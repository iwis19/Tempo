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
                    title: "Closed Days",
                    description: "\(closedStatements.count)"
                )
                MainCardBox(
                    title: "7D Net",
                    description: sevenDayNetCompactDisplay
                )
            }
        }
    }

    private var summaryCardRow: some View {
        HStack(alignment: .top, spacing: 8) {
            summaryCard(
                title: "Earned",
                value: CurrencyFormatter.string(earnedTotal, shorten: true, alwaysShowSign: true),
                subtitle: "All logged",
                tint: Color("tempoLeaf"),
                background: Color("tempoMintCard"),
                gain: true
            )
            summaryCard(
                title: "Required",
                value: CurrencyFormatter.string(requiredTotal, shorten: true, alwaysShowSign: true),
                subtitle: "All logged",
                tint: Color("tempoLossRed"),
                background: .white,
                gain: false
            )
            summaryCard(
                title: "Spent",
                value: CurrencyFormatter.string(spentTotal, shorten: true, alwaysShowSign: true),
                subtitle: "All logged",
                tint: Color("tempoLossRed"),
                background: Color("tempoNeutralCard"),
                gain: false
            )
        }
    }
    

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Your Previous Week")

            SurfaceCard {
                Text("Your week in a graph")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.60))
                
                Chart(graphData) { day in
                    BarMark(
                        x: .value("Day", day.dayLabel),
                        y: .value("Net", day.net),
                        width: 25
                    )
                    .foregroundStyle(day.net >= 0 ? positiveGradient : negativeGradient)
                    .annotation(position: day.net >= 0 ? .top : .bottom) {
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
                .padding(.bottom, 8)
                //.chartYAxis(.hidden)
                
                Text("Your week by the numbers")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.60))

                PreviewRow(
                    title: "Closed Days",
                    value: "\(closedStatements.count)",
                    tint: Color("tempoDeepGreen")
                )

                PreviewRow(
                    title: "7-Day Net",
                    value: sevenDayNetDisplay,
                    tint: sevenDayNetTint
                )

                PreviewRow(
                    title: "Avg Closed Day",
                    value: averageClosedDayDisplay,
                    tint: averageClosedDayTint
                )

                PreviewRow(
                    title: "Best Day",
                    value: bestDayDisplay,
                    tint: bestDayTint
                )
            }
        }
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

    private var recentStatements: [DayStatement] {
        Array(statementsWithEntries.prefix(5))
    }

    private var totalCash: Double {
        historyNetTotal + todayNetTotal
    }

    private var todayNetTotal: Double {
        net(for: todayStatement)
    }

    private var historyNetTotal: Double {
        pastStatements.reduce(0) { partialResult, statement in
            partialResult + net(for: statement)
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
        guard !closedStatements.isEmpty else {
            return 0
        }

        let total = closedStatements.reduce(0) { partialResult, statement in
            partialResult + net(for: statement)
        }

        return total / Double(closedStatements.count)
    }

    private var bestDayStatement: DayStatement? {
        statementsWithEntries.max { left, right in
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

    private var todayNetDisplay: String {
        guard hourlyRate > 0 else {
            return "Set rate"
        }

        if todayStatement.activities.isEmpty {
            return "No entries"
        }

        return CurrencyFormatter.string(todayNetTotal, alwaysShowSign: true)
    }

    private var runningTotalDisplay: String {
        guard hourlyRate > 0 else {
            return "Set rate"
        }

        if statementsWithEntries.isEmpty {
            return "No days"
        }

        return CurrencyFormatter.string(totalCash, alwaysShowSign: true)
    }

    private var hourlyRateDisplay: String {
        guard hourlyRate > 0 else {
            return "Set rate"
        }

        return "\(CurrencyFormatter.string(hourlyRate))/hr"
    }

    private var sevenDayNetDisplay: String {
        if sevenDayStatements.isEmpty {
            return "No days"
        }

        guard hourlyRate > 0 else {
            return "Set rate"
        }

        return CurrencyFormatter.string(sevenDayNet, alwaysShowSign: true)
    }

    private var sevenDayNetCompactDisplay: String {
        if sevenDayStatements.isEmpty {
            return "No days"
        }

        guard hourlyRate > 0 else {
            return "Set rate"
        }

        return CurrencyFormatter.string(sevenDayNet, shorten: true, alwaysShowSign: true)
    }

    private var averageClosedDayDisplay: String {
        if closedStatements.isEmpty {
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

    private var todayNetTint: Color {
        if hourlyRate <= 0 {
            return Color("tempoLossRed")
        }

        if todayStatement.activities.isEmpty {
            return Color("tempoInk")
        }

        return tone(for: todayNetTotal).amountColor
    }

    private var runningTotalTint: Color {
        if hourlyRate <= 0 {
            return Color("tempoLossRed")
        }

        if statementsWithEntries.isEmpty {
            return Color("tempoInk")
        }

        return tone(for: totalCash).amountColor
    }

    private var sevenDayNetTint: Color {
        if hourlyRate <= 0 {
            return Color("tempoLossRed")
        }

        if sevenDayStatements.isEmpty {
            return Color("tempoInk")
        }

        return tone(for: sevenDayNet).amountColor
    }

    private var averageClosedDayTint: Color {
        if hourlyRate <= 0 {
            return Color("tempoLossRed")
        }

        if closedStatements.isEmpty {
            return Color("tempoInk")
        }

        return tone(for: averageClosedDayNet).amountColor
    }

    private var bestDayTint: Color {
        guard let bestDayStatement else {
            return Color("tempoInk")
        }

        guard hourlyRate > 0 else {
            return Color("tempoDeepGreen")
        }

        return tone(for: net(for: bestDayStatement)).amountColor
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
        statement.activities
            .filter { $0.category == category }
            .reduce(0) { partialResult, activity in
                partialResult + amount(for: activity)
            }
    }

    private func net(for statement: DayStatement) -> Double {
        statement.activities.reduce(0) { partialResult, activity in
            partialResult + amount(for: activity)
        }
    }

    private func amount(for activity: Activity) -> Double {
        guard hourlyRate > 0 else {
            return 0
        }

        let hours = Double(activity.durationMinutes) / 60
        return hours * hourlyRate * activity.category.statementMultiplier
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

    private func statementTitle(for statement: DayStatement) -> String {
        if Calendar.current.isDateInToday(statement.date) {
            return "Today"
        }

        return statementDateText(for: statement.date)
    }

    private func statementSubtitle(for statement: DayStatement) -> String {
        let status = statement.isClosed ? "Closed" : "Open"
        let entryCount = statement.activities.count == 1 ? "1 entry" : "\(statement.activities.count) entries"
        return "\(status) • \(entryCount)"
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

private struct DashboardStatementRow: View {
    let title: String
    let subtitle: String
    let amount: Double

    private var tone: Flowtone {
        if amount > 0 {
            return .positive
        }

        if amount < 0 {
            return .negative
        }

        return .neutral
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Circle()
                .fill(tone.badgeBackground)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: tone.iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(tone.amountColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color("tempoInk"))

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.58))
            }

            Spacer()

            Text(CurrencyFormatter.string(amount, alwaysShowSign: true))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tone.amountColor)
        }
        .padding(.vertical, 6)
    }
}
