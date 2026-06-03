//
//  DemoData.swift
//  Tempo
//
//  Created by Codex on 2026-05-07.
//

import Foundation

enum DemoData {
    private static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    static let todayStatement = DayStatement(
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
        DayStatement(
            activities: [
                Activity(name: "Deep work sprint", length: 120, category: .earned),
                Activity(name: "Grocery run", length: 40, category: .required),
                Activity(name: "YouTube drift", length: 30, category: .spent)
            ],
            date: date(daysAgo: 1),
            isClosed: true
        ),
        DayStatement(
            activities: [
                Activity(name: "Client edits", length: 95, category: .earned),
                Activity(name: "Laundry", length: 35, category: .required),
                Activity(name: "Aimless scrolling", length: 25, category: .spent)
            ],
            date: date(daysAgo: 2),
            isClosed: true
        ),
        DayStatement(
            activities: [
                Activity(name: "Planning block", length: 70, category: .earned),
                Activity(name: "Meal prep", length: 40, category: .required),
                Activity(name: "Late scroll", length: 35, category: .spent)
            ],
            date: date(daysAgo: 3),
            isClosed: true
        ),
        DayStatement(
            activities: [
                Activity(name: "Study block", length: 75, category: .earned),
                Activity(name: "Commute", length: 50, category: .required),
                Activity(name: "Gaming detour", length: 45, category: .spent)
            ],
            date: date(daysAgo: 4),
            isClosed: true
        ),
        DayStatement(
            activities: [
                Activity(name: "Portfolio work", length: 90, category: .earned),
                Activity(name: "Errands", length: 45, category: .required),
                Activity(name: "Streaming break", length: 40, category: .spent)
            ],
            date: date(daysAgo: 5),
            isClosed: true
        ),
        DayStatement(
            activities: [
                Activity(name: "Admin reset", length: 45, category: .required),
                Activity(name: "Freelance proposal", length: 60, category: .earned)
            ],
            date: date(daysAgo: 6),
            isClosed: true
        )
    ]
}
