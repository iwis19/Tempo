//
//  DemoData.swift
//  Tempo
//
//  Created by Codex on 2026-05-07.
//

import Foundation

enum DemoData {
    private static let hourlyRate = 40.23

    private static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    private static func fixedDate(year: Int = 2026, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func statement(
        activities: [Activity],
        date: Date,
        isClosed: Bool
    ) -> DayStatement {
        let statement = DayStatement(
            activities: activities,
            date: date,
            isClosed: isClosed,
            hourlyRateSnapshot: hourlyRate
        )
        
        return StatementCalculator.snapshot(
            for: statement,
            hourlyRate: hourlyRate,
            isClosed: isClosed
        )
    }

    private static func historyStatement(
        month: Int,
        day: Int,
        earned: [Int],
        required: [Int],
        spent: [Int],
        title: String
    ) -> DayStatement {
        let date = fixedDate(month: month, day: day)
        var activities: [Activity] = []

        for (index, minutes) in earned.enumerated() where minutes > 0 {
            activities.append(Activity(name: "\(title) focus \(index + 1)", length: minutes, category: .earned, createdAt: date))
        }

        for (index, minutes) in required.enumerated() where minutes > 0 {
            activities.append(Activity(name: "\(title) required \(index + 1)", length: minutes, category: .required, createdAt: date))
        }

        for (index, minutes) in spent.enumerated() where minutes > 0 {
            activities.append(Activity(name: "\(title) drift \(index + 1)", length: minutes, category: .spent, createdAt: date))
        }

        return statement(
            activities: activities,
            date: date,
            isClosed: true
        )
    }

    static let todayStatement = statement(
        activities: [
            Activity(name: "Focused study", length: 80, category: .earned),
            Activity(name: "Commute", length: 45, category: .required),
            Activity(name: "Instagram drift", length: 50, category: .spent),
            Activity(name: "Admin catch-up", length: 35, category: .required)
        ],
        date: Date(),
        isClosed: false
    )

    static let pastStatements: [DayStatement] = [
        statement(
            activities: [
                Activity(name: "Deep work sprint", length: 120, category: .earned),
                Activity(name: "Grocery run", length: 40, category: .required),
                Activity(name: "YouTube drift", length: 30, category: .spent)
            ],
            date: date(daysAgo: 1),
            isClosed: true
        ),
        statement(
            activities: [
                Activity(name: "Client edits", length: 95, category: .earned),
                Activity(name: "Laundry", length: 35, category: .required),
                Activity(name: "Aimless scrolling", length: 25, category: .spent)
            ],
            date: date(daysAgo: 2),
            isClosed: true
        ),
        statement(
            activities: [
                Activity(name: "Planning block", length: 70, category: .earned),
                Activity(name: "Meal prep", length: 40, category: .required),
                Activity(name: "Late scroll", length: 35, category: .spent)
            ],
            date: date(daysAgo: 3),
            isClosed: true
        ),
        statement(
            activities: [
                Activity(name: "Study block", length: 75, category: .earned),
                Activity(name: "Commute", length: 50, category: .required),
                Activity(name: "Gaming detour", length: 45, category: .spent)
            ],
            date: date(daysAgo: 4),
            isClosed: true
        ),
        statement(
            activities: [
                Activity(name: "Portfolio work", length: 90, category: .earned),
                Activity(name: "Errands", length: 45, category: .required),
                Activity(name: "Streaming break", length: 40, category: .spent)
            ],
            date: date(daysAgo: 5),
            isClosed: true
        ),
        statement(
            activities: [
                Activity(name: "Admin reset", length: 45, category: .required),
                Activity(name: "Freelance proposal", length: 60, category: .earned)
            ],
            date: date(daysAgo: 6),
            isClosed: true
        ),
        statement(
            activities: [],
            date: Date(),
            isClosed: false
        )
    ]

    static let historyAnchorDate = fixedDate(month: 5, day: 27)

    static let historyStatements: [DayStatement] = [
        historyStatement(month: 1, day: 9, earned: [90, 70], required: [55], spent: [30], title: "January build"),
        historyStatement(month: 1, day: 22, earned: [50, 45], required: [35, 25], spent: [45, 35], title: "January reset"),
        historyStatement(month: 2, day: 7, earned: [80], required: [50, 40], spent: [70, 50], title: "February rough"),
        historyStatement(month: 2, day: 21, earned: [85, 65], required: [45], spent: [50], title: "February rebound"),
        historyStatement(month: 3, day: 13, earned: [95, 85], required: [40, 30], spent: [40], title: "March sprint"),
        historyStatement(month: 3, day: 27, earned: [70, 60], required: [55], spent: [20, 15], title: "March close"),
        historyStatement(month: 4, day: 10, earned: [100, 70], required: [45, 35], spent: [55], title: "April plan"),
        historyStatement(month: 4, day: 24, earned: [90, 80, 40], required: [60], spent: [25, 20], title: "April push"),
        historyStatement(month: 5, day: 8, earned: [100, 80], required: [60], spent: [25, 20], title: "May setup"),
        historyStatement(month: 5, day: 16, earned: [90, 70, 45], required: [50], spent: [30], title: "May deep work"),
        historyStatement(month: 5, day: 24, earned: [75], required: [35], spent: [35, 25], title: "Sunday spill"),
        historyStatement(month: 5, day: 25, earned: [80, 70], required: [45], spent: [25], title: "Monday start"),
        historyStatement(month: 5, day: 26, earned: [70, 55], required: [50], spent: [25, 15], title: "Tuesday edits"),
        historyStatement(month: 5, day: 27, earned: [90, 80, 60], required: [50, 42], spent: [65, 45], title: "Wednesday archive"),
        historyStatement(month: 5, day: 28, earned: [70], required: [35, 30], spent: [60, 45], title: "Thursday wobble"),
        historyStatement(month: 5, day: 29, earned: [90, 70, 40], required: [55], spent: [40], title: "Friday finish"),
        historyStatement(month: 5, day: 30, earned: [55, 40], required: [35], spent: [35], title: "Saturday cleanup"),
        historyStatement(month: 5, day: 31, earned: [70, 50], required: [40], spent: [20], title: "Sunday review"),
        historyStatement(month: 6, day: 4, earned: [80, 65], required: [40, 30], spent: [35, 30], title: "June admin"),
        historyStatement(month: 6, day: 5, earned: [100, 90], required: [45], spent: [30, 25], title: "June client"),
    ]
}
