//
//  HistoryPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-03.
//

import SwiftUI
import Foundation

struct HistoryPage: View {
    
    @Environment(UserStore.self) private var userStore
    
    @State private var selectedType: ChartType = .day  // default type is day
    @State private var selectedDay: Date = yesterday // default date is yesterday
    
    private var hourlyRate: Double { userStore.setting.hourlyRate }
    private var pastStatement: [DayStatement] { userStore.pastStatement }
    
    private var periodIntervalStatement: [DayStatement] { statements(in: periodInterval) }
    private var previousPeriodIntervalStatement: [DayStatement] { statements(in: previousPeriodInterval)}
    
    private var netTotal: Double { allNet(for: periodIntervalStatement) }
    private var previousNetTotal: Double { allNet(for: previousPeriodIntervalStatement) }
    
    private var netTotalDisplay: String {
        CurrencyFormatter.string(netTotal, shorten: true, alwaysShowSign: true)
    }
    
    private var previousNetTotalDisplay: String {
        CurrencyFormatter.string(previousNetTotal, shorten: true, alwaysShowSign: true)
    }
    
    private func statements(in interval: DateInterval) -> [DayStatement] {
        pastStatement.filter { statement in
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
            if statement.isClosed {
                return partialResult + statement.netTotal
            }

            return partialResult + StatementCalculator.netTotal(
                for: statement,
                hourlyRate: hourlyRate
            )
        }
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
                total = statement.earnedTotal
            case .required:
                total = statement.requiredTotal
            case .spent:
                total = statement.spentTotal
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
            mainCard
            categoryBreakdown
            graphBreakdown
            statementListing
        }
    }
    
    private var rangeSelector: some View {
        HStack (alignment: .center, spacing: 7){
            ForEach(ChartType.allCases) { type in
                Button(
                    action:{
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)){
                            selectedType = type
                        }
                    }
                ){
                    Text(type.shortTitle)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedType == type ? Color.white : Color("tempoInk"))
                        .background(selectedType == type ? Color("tempoDeepGreen") : Color.white.opacity(0.76))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color("tempoLeaf").opacity(selectedType == type ? 0 : 0.12), lineWidth: 1)
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
                    .foregroundStyle(Color("tempoInk"))
                
                Text(selectedType.navigationSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.58))
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
                .stroke(Color("tempoLeaf").opacity(0.10), lineWidth: 1)
        }
    }
    
    private var statusBadgeText: String {
        let prev = previousNetTotal
        let now = netTotal
        
        return CurrencyFormatter.string(now - prev, shorten: true, alwaysShowSign: true) + " From Previous"
    }
    
    private var mainCard: some View {
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
            
            Text("subtitle that makes sense")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.84))
            
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
    
    private var bestDayStatementNet: String {
        guard let statement = bestDayStatement else {
            return CurrencyFormatter.string(0, shorten: true)
        }
        
        return CurrencyFormatter.string(statement.netTotal, shorten: true)
    }
    
    private var bestDayStatement: DayStatement? {
        periodIntervalStatement.max { left, right in
            left.netTotal < right.netTotal
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
    
    private var graphBreakdown: some View {
        SurfaceCard {
            SectionTitle(
                title: "\(selectedType.longTitle) Breakdown",
                subtitle: nil
            )
            
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
    
    private var statementListing: some View {
        
        VStack (alignment: .leading, spacing: 14) {
            SectionTitle(
                title: "Statements in This Period",
                subtitle: nil
            )

            if statementList.isEmpty {
                SurfaceCard {
                    Text("hello")
                        .foregroundStyle(Color("tempoInk"))
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
    
    private func temporaryMoveDate (_ value: Int) -> Date {
        return Calendar.current.date(
            byAdding: selectedType.navigationComponent,
            value: selectedType.navigationStep * value,
            to: selectedDay) ?? Date()
    }
    
    // only used for moving forward, so value from temporaryMoveDate is assumed 1
    private var navigationButtonDisabled: Bool {
        if Calendar.current.startOfDay(for: temporaryMoveDate(1)) >= Calendar.current.startOfDay(for: Date()) {
            return true
        }
        return false
    }
    
    private func movePeriod (_ value: Int) {
        
        let newDate = temporaryMoveDate(value)
        
        if Calendar.current.startOfDay(for: newDate) < Calendar.current.startOfDay(for: Date()) {
            selectedDay = newDate
        }
    }

    private static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
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
            return periodIntervalStatement
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
            
            let monthStatements = statements(in: DateInterval(start: start, end: end))
            
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
    userStore.pastStatement = DemoData.historyStatements
    userStore.setting.hourlyRate = 40.23
    
    return HistoryPage()
        .environment(userStore)
}
