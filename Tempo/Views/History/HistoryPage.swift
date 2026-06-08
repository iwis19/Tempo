//
//  HistoryPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-03.
//

import SwiftUI
import Foundation
import Charts

struct HistoryPage: View {
    
    @Environment(UserStore.self) private var userStore
    
    @State private var selectedType: ChartType = .day  // default type is day
    @State private var selectedDay: Date = Date() // default date is today
    
    @State private var selectedPeriod: String?
    
    private var hourlyRate: Double { userStore.setting.hourlyRate }
    private var todayStatement: DayStatement { userStore.todayStatement }
    private var pastStatements: [DayStatement] { userStore.pastStatements }
    
    private var allStatements: [DayStatement] {
        pastStatements + [todayStatement]
    }
    
    private var periodIntervalStatement: [DayStatement] { statements(in: periodInterval) }
    private var previousPeriodIntervalStatement: [DayStatement] { statements(in: previousPeriodInterval)}
    
    private var netTotal: Double { allNet(for: periodIntervalStatement) }
    private var previousNetTotal: Double { allNet(for: previousPeriodIntervalStatement) }
    private var periodDelta: Double { netTotal - previousNetTotal }
    
    private var positive: Bool { netTotal >= 0 }
    
    var body: some View {
        PageContainer {
            PageHeader(
                eyebrow: "History",
                title: nil,
                subtitle: nil
            )
            
            rangeSelector
            periodNavigator
            statementCard
            categoryBreakdown
            periodBreakdown
            
            if showStatementListing{
                statementListing
            }
        }
    }
    
    private var rangeSelector: some View {
        HStack (alignment: .center, spacing: 7){
            ForEach(ChartType.allCases) { type in
                Button(
                    action:{
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)){
                            selectedType = type
                            selectedPeriod = nil
                        }
                    }
                ){
                    Text(type.shortTitle)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedType == type ? Color.white : .tempoInk)
                        .background(selectedType == type ? .tempoDeepGreen : Color.white.opacity(0.76))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.tempoLeaf.opacity(selectedType == type ? 0 : 0.12), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var periodNavigator: some View {
        HStack {
            
            NavigationButton(icon: "chevron.left") {
                movePeriod(-1)
            }
            
            Spacer()
            
            VStack (alignment: .center){
                Text(selectedTypeTitle)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.tempoInk)
                
                Text(selectedType.navigationSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.tempoInk.opacity(0.58))
            }
            
            Spacer()
            
            NavigationButton(icon: "chevron.right") {
                movePeriod(1)
            }
            .disabled(navigationButtonDisabled)
            
        }
        .frame(maxWidth: .infinity, minHeight: 65)
        .padding(14)
        .background(Color.white.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.tempoLeaf.opacity(0.10), lineWidth: 1)
        }
    }
    
    private var statementCard: some View {
        MainCard (positive: positive) {
            HStack (alignment: .top){
                Text(selectedType.mainCardTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .offset(y: 8)
                
                Spacer()
                
                MainCardStatusBadge(text: statusBadgeText, positive: positive)
            }
            
            Text(netTotalDisplay)
                .font(.custom("Syne-Regular", size: 46))
                .foregroundStyle(Color.white)
            
            Text(statementCardSubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.84))
                .padding(.bottom, 5)
            
            HStack (spacing: 8) {
                MainCardBox(
                    title: "Logged Days",
                    description: "\(loggedDays)"
                )
                MainCardBox(
                    title: "Avg Logged Day",
                    description: avgLoggedDay
                )
            }
            
            HStack (spacing: 8) {
                MainCardBox(
                    title: "Best Day",
                    description: bestDayStatementNet
                )
                MainCardBox(
                    title: "Spent Share",
                    description: "\(spentShare)%"
                )
            }
        }
    }
    
    private var categoryBreakdown: some View {
        SurfaceCard {
            SectionTitle(
                title: "Category Breakdown",
                subtitle: "Here is a breakdown of your \(selectedType.shortTitle.lowercased()):"
            )
            
            CategoryMixBar(
                totalTime: categoryMinutes(for: .earned, in: periodIntervalStatement),
                percent: categoryShare(for: .earned),
                amount: categoryNet(for: .earned, in: periodIntervalStatement),
                activity: .earned
            )
            CategoryMixBar(
                totalTime: categoryMinutes(for: .required, in: periodIntervalStatement),
                percent: categoryShare(for: .required),
                amount: categoryNet(for: .required, in: periodIntervalStatement),
                activity: .required
            )
            CategoryMixBar(
                totalTime: categoryMinutes(for: .spent, in: periodIntervalStatement),
                percent: categoryShare(for: .spent),
                amount: categoryNet(for: .spent, in: periodIntervalStatement),
                activity: .spent
            )
        }
    }
    
    private var periodBreakdown: some View {
        SurfaceCard {
            SectionTitle(
                title: "\(selectedType.longTitle) Breakdown",
                subtitle: nil
            )
            
            Text("Trends (\(selectedType.breakdownText))")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.tempoInk.opacity(0.85))
                .padding(.bottom, 4)
            
            if !hasGraphData(for: periodInterval) {
                Text("You have no trends in this period.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tempoInk.opacity(0.65))
                        .padding(.bottom, 8)
            }
            else {
                Chart(graphData) { data in
                    BarMark(
                        x: .value("Period", data.label),
                        y: .value("Net", data.net)
                    )
                    .cornerRadius(8)
                    .foregroundStyle(data.net >= 0 ? positiveGradient(graph: true) : negativeGradient(graph: true))
                    .annotation(
                        position: data.net >= 0 ? .top : .bottom,
                        overflowResolution:
                            .init(x: .fit, y: .disabled)
                    ){
                        if selectedPeriod == data.label {
                            let netDisplay = String(format: "%.2f", abs(data.net))
                            
                            Text(data.net >= 0 ? "+$\(netDisplay)" : "-$\(netDisplay)")
                                .foregroundStyle(.tempoInk)
                                .font(.system(size: 17))
                                .padding(6)
                                .background(Color(.white))
                                .clipShape(RoundedRectangle(cornerRadius:8))
                        }
                    }
                }
                .frame(height: 200)
                .padding(.top, 6)
                .padding(.horizontal, 5)
                .padding(.bottom, 20)
                .chartXSelection(value: $selectedPeriod)
                .chartXScale(
                    range:
                        .plotDimension(
                            startPadding: 6,
                            endPadding: 6
                        )
                )
                .chartXAxis{
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
            }
            
            Text("Statistics")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.tempoInk.opacity(0.85))
                .padding(.bottom, 4)
            
            PreviewRow(
                title: "Previous \(selectedType.longTitle)",
                value: previousNetTotalDisplay,
                tint: previousDayColor.tint,
                background: previousDayColor.background
            )
            
            PreviewRow(
                title: "Most Active Category",
                value: mostActiveCategory,
                tint: mostActiveCategoryColor.tint,
                background: mostActiveCategoryColor.background
            )
        }
    }
    
    private func hasGraphData(for interval: DateInterval) -> Bool {
        let statements = statements(in: interval)
        
        return statements.contains { statement in
            statement.activities.count > 0
        }
    }
    
    private func withinDayGraphData(for interval: DateInterval) -> [GraphData] {
        
        let dayStatement: [DayStatement] = statements(in: interval)
        
        return DayPart.allCases.map { part in
            let total = dayStatement.reduce(0) { statementTotal, statement in
                let rate = statement.isClosed ? statement.hourlyRateSnapshot : hourlyRate

                let activityTotal = statement.activities
                    .filter { DayPart.of($0.createdAt) == part }
                    .reduce(0) { total, activity in
                        total + ActivityCalculator.amount(for: activity, hourlyRate: rate)
                    }

                return statementTotal + activityTotal
            }
            
            return GraphData(label: part.title, net: total)
        }
    }
    
    private func dayGraphData(for interval: DateInterval) -> [GraphData] {
        
        var data: [GraphData] = []
        var day: Date = interval.start
        
        while day < interval.end {
            let nextDay = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: day
            ) ?? interval.end
            
            let dayInterval = DateInterval(start: day, end: nextDay)
            let label = day.formatted(.dateTime.weekday(.abbreviated))
            
            data.append(
                GraphData(
                    label: label,
                    net: allNet(for: statements(in: dayInterval))
                )
            )
            
            day = nextDay
        }
        
        return data
    }
    
    private func weekGraphData(for interval: DateInterval) -> [GraphData] {
        
        var data: [GraphData] = []
        var week: Int = 1
        var start: Date = interval.start
        
        while start < interval.end {
            let nextEnd = Calendar.current.date(
                byAdding: .day,
                value: 7,
                to: start
            ) ?? interval.end
            let end = nextEnd < interval.end ? nextEnd : interval.end
            let weekInterval = DateInterval(start: start, end: end)
            let label = "W\(week)"
            
            data.append(
                GraphData(
                    label: label, net: allNet(for: statements(in: weekInterval)))
            )
            
            start = end
            week += 1
        }
        
        return data
        
    }
    
    private func monthGraphData(for interval: DateInterval, count: Int) -> [GraphData] {
        
        (0..<count).compactMap { offset in
            guard
                let start = Calendar.current.date(byAdding: .month, value: offset, to: interval.start),
                let end = Calendar.current.date(byAdding: .month, value: 1, to: start)
            else {
                return nil
            }
            
            let label = start.formatted(.dateTime.month(.abbreviated))
            
            return GraphData(label: label, net: allNet(for: statements(in: DateInterval(start: start, end: end))))
        }
    }
    
    private var graphData: [GraphData] {
        switch selectedType {
        case .day:
            return withinDayGraphData(for: periodInterval) // give category
        case .week:
            return dayGraphData(for: periodInterval) // give day
        case .month:
            return weekGraphData(for: periodInterval) // give week
        case .quarter:
            return monthGraphData(for: periodInterval, count: 3)
        case .year:
            return monthGraphData(for: periodInterval, count: 12) // give month
        }
    }
    
    private var netTotalDisplay: String {
        CurrencyFormatter.string(netTotal, shorten: true, alwaysShowSign: true)
    }
    
    private var previousNetTotalDisplay: String {
        CurrencyFormatter.string(previousNetTotal, shorten: true, alwaysShowSign: true)
    }
    
    private func statements(in interval: DateInterval) -> [DayStatement] {
        allStatements.filter { statement in
            let statementDay = Calendar.current.startOfDay(for: statement.date)
            return statementDay >= interval.start && statementDay < interval.end
        }
    }
    
    private func totalEntries(in statements: [DayStatement]) -> Int {
        statements.reduce(0) { partialResult, statement in
            partialResult + statement.activities.count
        }
    }
    
    private func statementsWithEntries(for statements: [DayStatement]) -> [DayStatement] {
        return statements
            .filter { !$0.activities.isEmpty }
            .sorted { $0.date > $1.date }
    }
    
    private func allNet(for statements: [DayStatement]) -> Double {
        statements.reduce(0) { partialResult, statement in
            partialResult + net(for: statement)
        }
    }
    
    private func net(for statement: DayStatement) -> Double {
        statement.isClosed ? statement.netTotal : StatementCalculator.netTotal(for: statement, hourlyRate: hourlyRate)
    }
    
    private func categoryMinutes(for category: ActivityCategory, in statements: [DayStatement]) -> Int {
        statements.reduce(0) { partialResult, statement in
            partialResult + statement.activities
                .filter { $0.category == category }
                .reduce(0) { activityTotal, activity in
                    activityTotal + activity.durationMinutes
                }
        }
    }
    
    private func categoryNet(for category: ActivityCategory, in statements: [DayStatement]) -> Double {
        statements.reduce(0) { partialResult, statement in
            var total: Double

            switch category {
            case .earned:
                total = statement.isClosed ? statement.earnedTotal : StatementCalculator.total(for: .earned, in: statement, hourlyRate: hourlyRate)
            case .required:
                total = statement.isClosed ? statement.requiredTotal : StatementCalculator.total(for: .required, in: statement, hourlyRate: hourlyRate)
            case .spent:
                total = statement.isClosed ? statement.spentTotal : StatementCalculator.total(for: .spent, in: statement, hourlyRate: hourlyRate)
            }

            return partialResult + total
        }
    }
    
    private func categoryShare(for category: ActivityCategory) -> Double {
        let total = categoryMinutes(for: .earned, in: periodIntervalStatement) + categoryMinutes(for: .required, in: periodIntervalStatement) + categoryMinutes(for: .spent, in: periodIntervalStatement)

        guard total > 0 else {
            return 0
        }
        
        return Double(categoryMinutes(for: category, in: periodIntervalStatement)) / Double(total)
    }
    
    private var showStatementListing: Bool {
        return selectedType != .day
    }
    
    private var statementListing: some View {
        
        VStack (alignment: .leading, spacing: 14) {
            SectionTitle(
                title: "\(selectedType.statementListingText) in This Period",
                subtitle: nil
            )

            if statementList.isEmpty {
                SurfaceCard {
                    Text("No statements logged in this period.")
                        .foregroundStyle(.tempoInk)
                }
            }
            else {
                ForEach(statementList) { statement in
                    statementCompactRow(
                        statement: statement
                    )
                }
            }
        }
    }
    
    private var statusBadgeText: String {
        CurrencyFormatter.string(periodDelta, shorten: true, alwaysShowSign: true) + " From Previous"
    }
    
    private var statementCardSubtitle: String {
        guard loggedDays > 0 else {
            return "No logged statements in this period."
        }

        return "Net change across \(loggedDays) logged days."
    }
    
    private var bestDayStatementNet: String {
        guard let statement = bestDayStatement else {
            return CurrencyFormatter.string(0, shorten: true)
        }
        
        return CurrencyFormatter.string(net(for: statement), shorten: true)
    }
    
    private var bestDayStatement: DayStatement? {
        periodIntervalStatement.max { left, right in
            net(for: left) < net(for: right)
        }
    }
    
    private var loggedDays: Int {
        statementsWithEntries(for: periodIntervalStatement).count
    }
    
    private var avgLoggedDay: String {
        guard loggedDays > 0 else {
            return CurrencyFormatter.string(0, shorten: true)
        }

        return CurrencyFormatter.string(netTotal / Double(loggedDays), shorten: true)
    }
    
    private var spentShare: Int {
        Int(categoryShare(for: .spent) * 100)
    }
    
    private var mostActiveCategory: String {
        let earned = categoryMinutes(for: .earned, in: periodIntervalStatement)
        let spent = categoryMinutes(for: .spent, in: periodIntervalStatement)
        let required = categoryMinutes(for: .required, in: periodIntervalStatement)
        
        if earned == spent && spent == required {
            return "None"
        }
        
        if earned >= required && earned >= spent {
            return "Earned"
        }
        
        if required >= earned && required >= spent {
            return "Required"
        }
        
        if spent >= earned && spent >= required {
            return "Spent"
        }
        
        return "Error"
    }

    private var mostActiveCategoryColor: Flowtone {
        if mostActiveCategory == "None" || mostActiveCategory == "Error" {
            return .neutral
        }
        if mostActiveCategory == "Spent" {
            return .negative
        }
        if mostActiveCategory == "Earned" {
            return .positive
        }
        return .neutral
    }
    
    private var previousDayColor: Flowtone {
        guard previousNetTotal != 0 else {
            return .neutral
        }
        
        return previousNetTotal > 0 ? .positive : .negative
    }
    
    private func temporaryMoveDate (_ value: Int) -> Date {
        return Calendar.current.date(
            byAdding: selectedType.navigationComponent,
            value: selectedType.navigationStep * value,
            to: selectedDay) ?? Date()
    }
    
    // only used for moving forward, so value from temporaryMoveDate is assumed 1
    private var navigationButtonDisabled: Bool {
        let targetInterval = interval(for: selectedType, containing: temporaryMoveDate(1))
        return targetInterval.start > Calendar.current.startOfDay(for: Date())
    }
    
    private func movePeriod (_ value: Int) {
        let newDate = temporaryMoveDate(value)
        let targetInterval = interval(for: selectedType, containing: newDate)
        let today = Calendar.current.startOfDay(for: Date())
        
        guard targetInterval.start <= today else {
            return
        }
        
        selectedPeriod = nil
        
        if value > 0 && Calendar.current.startOfDay(for: newDate) > today && today < targetInterval.end {
            selectedDay = today
        }
        else {
            selectedDay = newDate
        }
    }
    
    private var selectedTypeTitle: String {
        switch selectedType {
        case .day:
            CalendarFormatter.dayTitle(for: selectedDay)
        case .week:
            CalendarFormatter.weekTitle(for: selectedDay)
        case .month:
            CalendarFormatter.monthTitle(for: selectedDay)
        case .quarter:
            CalendarFormatter.quarterTitle(for: selectedDay)
        case .year:
            CalendarFormatter.yearTitle(for: selectedDay)
        }
    }
    
    private var periodInterval: DateInterval {
        interval(for: selectedType, containing: selectedDay)
    }
    
    private var previousPeriodInterval: DateInterval {
        let previousAnchor = Calendar.current.date(
            byAdding: selectedType.navigationComponent,
            value: selectedType.navigationStep * -1,
            to: selectedDay
        ) ?? selectedDay
        
        return interval(for: selectedType, containing: previousAnchor)
    }
    
    private func interval(for type: ChartType, containing date: Date) -> DateInterval {
        switch type {
        case .day:
            let start = Calendar.current.startOfDay(for: date)
            let end = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: start
            ) ?? start
            return DateInterval(start: start, end: end)
        case .week:
            return Calendar.current.dateInterval(of: .weekOfYear, for: date) ?? interval(for: .day, containing: date)
        case .month:
            return Calendar.current.dateInterval(of: .month, for: date) ?? interval(for: .day, containing: date)
        case .quarter:
            let month = Calendar.current.component(.month, from: date)
            let year = Calendar.current.component(.year, from: date)
            let quarterStartMonth = ((month-1)/3) * 3 + 1
            let start = Calendar.current.date(from: DateComponents(year: year, month: quarterStartMonth, day: 1)) ?? date
            let end = Calendar.current.date(byAdding: .month, value: 3, to: start) ?? start
            return DateInterval(start: start, end: end)
        case .year:
            return Calendar.current.dateInterval(of: .year, for: date) ?? interval(for: .day, containing: date)
        }
    }
    
    private func summary(for statements: [DayStatement], date: String) -> StatementSummary {
        StatementSummary(
            date: date,
            netTotal: allNet(for: statements),
            entries: totalEntries(in: statements),
            earnedMinutes: TimeFormatter.minuteCountString(minutes: categoryMinutes(for: .earned, in: statements)),
            requiredMinutes: TimeFormatter.minuteCountString(minutes: categoryMinutes(for: .required, in: statements)),
            spentMinutes: TimeFormatter.minuteCountString(minutes: categoryMinutes(for: .spent, in: statements))
        )
    }
    
    private var statementList: [StatementSummary] {
        switch selectedType {
        case .day, .week, .month:
            return statementsWithEntries(for: periodIntervalStatement)
                .sorted { $0.date < $1.date }
                .map { summary(for: [$0], date: CalendarFormatter.dayTitle(for: $0.date))}
        case .quarter:
            return monthSummaries(in: periodInterval, count: 3)
        case .year:
            return monthSummaries(in: periodInterval, count: 12)
        }
    }
    
    private func monthSummaries(in interval: DateInterval, count: Int) -> [StatementSummary] {
        (0..<count).compactMap { offset in
            guard
                let start = Calendar.current.date(
                    byAdding: .month,
                    value: offset,
                    to: interval.start
                ),
                let end = Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: start
                )
            else {
                return nil
            }
            
            let monthStatements = statementsWithEntries(for: statements(in: DateInterval(start: start, end: end)))
            
            guard !monthStatements.isEmpty else {
                return nil
            }
            
            return summary(
                for: monthStatements,
                date: start.formatted(.dateTime.month(.abbreviated).year())
            )
        }
    }
}

#Preview {
    let userStore = UserStore()
    userStore.todayStatement = DemoData.todayStatement
    userStore.pastStatements = DemoData.historyStatements
    userStore.setting.hourlyRate = 40.23
    
    return HistoryPage()
        .environment(userStore)
}
