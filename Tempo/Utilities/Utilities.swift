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
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    
    static func string(_ number: Double, alwaysShowSign: Bool = false) -> String {
        let absolute = abs(number)
        let formatted = formatter.string(from: NSNumber(value: absolute)) ?? "0"
        
        if number < 0 {
            return "-\(formatted)"
        }
            
        else if alwaysShowSign && number > 0 {
            return "+\(formatted)"
        }
        
        return formatted
        
    }
}

struct RateFormatter {
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


