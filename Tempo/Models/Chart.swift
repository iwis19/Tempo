//
//  ChartType.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-04.
//

import Foundation

enum ChartType: CaseIterable, Identifiable {
    case day
    case week
    case month
    case quarter
    case year
    
    var id: String { self.shortTitle }
    
    var shortTitle: String {
        switch self{
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .quarter:
            return "Qtr"
        case .year:
            return "Year"
        }
    }
    
    var longTitle: String {
        switch self{
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .quarter:
            return "Quarter"
        case .year:
            return "Year"
        }
    }
    
    var mainCardTitle: String {
        switch self{
        case .day:
            return "DAY NET"
        case .week:
            return "WEEK NET"
        case .month:
            return "MONTH NET"
        case .quarter:
            return "QUARTER NET"
        case .year:
            return "YEAR NET"
        }
    }
    
    var chartTitle: String {
        switch self{
        case .day:
            return "Day Breakdown"
        case .week:
            return "Week by Day"
        case .month:
            return "Month by Week"
        case .quarter:
            return "Quarter by Month"
        case .year:
            return "Year by Month"
        }
    }
    
    var navigationSubtitle: String {
        switch self{
        case .day:
            return "Single day statement"
        case .week:
            return "Full week, grouped by day"
        case .month:
            return "Full month, grouped by week"
        case .quarter:
            return "Three months, grouped by month"
        case .year:
            return "Full year, grouped by month"
        }
    }
    
    var navigationComponent: Calendar.Component {
        switch self{
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        case .quarter:
            return .month
        case .year:
            return .year
        }
    }
    
    var navigationStep: Int {
        switch self{
        case .quarter:
            return 3
        default:
            return 1
        }
    }
    
    var statementListingText: String {
        switch self {
        case .day:
            return "N/A"
        case .week:
            return "Days"
        case .month:
            return "Days"
        case .quarter:
            return "Months"
        case .year:
            return "Months"
        }
    
    }
    
    var breakdownText: String {
        switch self {
        case .day:
            return "by time of day"
        case .week:
            return "by day"
        case .month:
            return "by week"
        case .quarter, .year:
            return "by month"
        }
    }
    
    
    
}
