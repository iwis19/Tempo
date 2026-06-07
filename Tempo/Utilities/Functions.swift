//
//  CurrencyFormatter.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-26.
//

import Foundation

struct CurrencyFormatter {
    
    // not a func since this is basically just a variable of something that does stuff
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    
    static func string(_ number: Double, shorten: Bool = false, alwaysShowSign: Bool = false) -> String {
        let absolute = abs(number)
        var formatted: String
        
        if shorten && absolute >= 1000 && absolute < 1000000 {
            formatted = "$\(DecimalFormatter.string(absolute / 1_000.0))K"
        }
        else if shorten && absolute >= 1000000 {
            formatted = "$\(DecimalFormatter.string(absolute / 1_000_000.0))M"
        }
        else {
            formatted = formatter.string(from: NSNumber(value: absolute)) ?? "0"
        }
        
        if number < 0 {
            return "-\(formatted)"
        }
        else if alwaysShowSign && number > 0 {
            return "+\(formatted)"
        }
        return formatted
    }
}

struct DecimalFormatter {
    static func string(_ rate: Double) -> String {
        var text = String(format: "%.2f", rate)
        while text.contains(".") && text.last == "0" {
            text.removeLast()
        }
        if text.last == "." {
            text.removeLast()
        }
        
        return text
    }
}

struct TimeFormatter {
    static func reminderString(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        let timestamp = Calendar.current.date(from: components)
        
        guard let date = timestamp else {
            return "8:00 PM"
        }
        
        return formatter.string(from: date)
    }
    
    static func minuteCountString(minutes: Int) -> String {
        
        // start from mins -> hours -> days -> weeks -> month
        
        var output: String = ""
        
        var mins: Int = minutes
        
        let weeks: Int = mins / 10080
        mins %= 10080
        
        let days: Int = mins / 1440
        mins %= 1440
        
        let hours: Int = mins / 60
        mins %= 60

        if weeks != 0 {
            output.append("\(weeks)w ")
        }
        
        if days != 0 {
            output.append("\(days)d ")
        }
        
        if hours != 0 {
            output.append("\(hours)h ")
        }
        
        output.append("\(mins)m")
        
        return output
    }
    
    static func greetingText(for day: Date) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
            case 0..<12: return "Good morning"
            case 12..<18: return "Good afternoon"
            case 18...: return "Good evening"
            default: return "Hello"
        }
    }
}

struct CalendarFormatter {
    static func dayTitle(for date: Date) -> String {
        let month = date.formatted(.dateTime.month(.wide))
        let day = Calendar.current.component(.day, from: date)

        let ordinal = NumberFormatter()
        ordinal.numberStyle = .ordinal

        return "\(month) \(ordinal.string(from: NSNumber(value: day)) ?? "\(day)")"
    }

    static func weekTitle(for date: Date) -> String {
        let calendar = Calendar.current

        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date),
              let end = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
            return dayTitle(for: date)
        }

        let startText = interval.start.formatted(.dateTime.month(.abbreviated).day())
        let endText = end.formatted(.dateTime.month(.abbreviated).day())

        return "\(startText) - \(endText)"
    }

    static func monthTitle(for date: Date) -> String {
        date.formatted(.dateTime.month(.wide).year())
    }

    static func quarterTitle(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        let quarter = ((month - 1) / 3) + 1

        return "Q\(quarter) \(year)"
    }

    static func yearTitle(for date: Date) -> String {
        date.formatted(.dateTime.year())
    }
}


struct ActivityCalculator {
    static func amount(for activity: Activity, hourlyRate: Double) -> Double {
        guard hourlyRate > 0 else {
            return 0
        }

        let hours = Double(activity.durationMinutes) / 60
        return hours * hourlyRate * activity.category.statementMultiplier
    }
}

struct StatementCalculator {
    static func total(for category: ActivityCategory, in statement: DayStatement, hourlyRate: Double) -> Double {
        statement.activities
            .filter { $0.category == category }
            .reduce(0) { partialResult, activity in
                partialResult + ActivityCalculator.amount(for: activity, hourlyRate: hourlyRate)
            }
    }
    
    static func netTotal(for statement: DayStatement, hourlyRate: Double) -> Double {
        ActivityCategory.allCases.reduce(0) { partialResult, category in
            partialResult + total(for: category, in: statement, hourlyRate: hourlyRate)
        }
    }
    
    static func snapshot(for statement: DayStatement, hourlyRate: Double, isClosed: Bool) -> DayStatement {
        let earnedTotal = total(for: .earned, in: statement, hourlyRate: hourlyRate)
        let requiredTotal = total(for: .required, in: statement, hourlyRate: hourlyRate)
        let spentTotal = total(for: .spent, in: statement, hourlyRate: hourlyRate)
        
        return DayStatement(
            id: statement.id,
            activities: statement.activities,
            date: statement.date,
            isClosed: isClosed,
            hourlyRateSnapshot: hourlyRate,
            earnedTotal: earnedTotal,
            requiredTotal: requiredTotal,
            spentTotal: spentTotal,
            netTotal: earnedTotal + requiredTotal + spentTotal
        )
    }
}
