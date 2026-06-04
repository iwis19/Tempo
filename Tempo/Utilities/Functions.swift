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
    static func string(hour: Int, minute: Int) -> String {
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
