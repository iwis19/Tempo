//
//  DemoData.swift
//  Tempo
//
//  Created by Codex on 2026-05-07.
//

import Foundation

enum DemoData {
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

    static let cashSnapshot = CashDashboardSnapshot(
        monthlyIncome: 7_420,
        monthlyPlannedBills: 3_120,
        monthlyFlexibleSpend: 1_660,
        buckets: [
            CashBucket(
                title: "Main Balance",
                subtitle: "Cash that is truly free to move this week.",
                amount: 6_375,
                iconName: "creditcard.fill",
                kind: .available
            ),
            CashBucket(
                title: "Bills Vault",
                subtitle: "Rent, utilities, subscriptions, and upcoming autopays.",
                amount: 3_240,
                iconName: "calendar.badge.clock",
                kind: .vaulted
            ),
            CashBucket(
                title: "Emergency Reserve",
                subtitle: "Safety money that protects the month from surprise shocks.",
                amount: 12_600,
                iconName: "shield.lefthalf.filled",
                kind: .reserved
            ),
            CashBucket(
                title: "Travel Plan",
                subtitle: "A future-purpose bucket that is already assigned.",
                amount: 980,
                iconName: "airplane",
                kind: .planned
            )
        ],
        upcomingItems: [
            UpcomingCashMove(
                title: "Rent Autopay",
                subtitle: "Friday from Bills Vault",
                amount: -1_850
            ),
            UpcomingCashMove(
                title: "Freelance Deposit",
                subtitle: "Tuesday morning",
                amount: 2_400
            ),
            UpcomingCashMove(
                title: "Reserve Transfer",
                subtitle: "Next Monday",
                amount: -450
            )
        ]
    )
}

enum TempoMath {
    static func amount(for activity: Activity, hourlyRate: Double) -> Double {
        guard hourlyRate > 0 else {
            return 0
        }

        let hours = Double(activity.durationMinutes) / 60
        return hours * hourlyRate * activity.category.statementMultiplier
    }

    static func statementTotal(for category: ActivityCategory, in statement: DayStatement, hourlyRate: Double) -> Double {
        statement.activities
            .filter { $0.category == category }
            .reduce(0) { partialResult, activity in
                partialResult + amount(for: activity, hourlyRate: hourlyRate)
            }
    }

    static func statementNetTotal(in statement: DayStatement, hourlyRate: Double) -> Double {
        statement.activities.reduce(0) { partialResult, activity in
            partialResult + amount(for: activity, hourlyRate: hourlyRate)
        }
    }

    static func totalCash(in snapshot: CashDashboardSnapshot) -> Double {
        snapshot.buckets.reduce(0) { partialResult, bucket in
            partialResult + bucket.amount
        }
    }

    static func cashTotal(for kind: CashBucketKind, in snapshot: CashDashboardSnapshot) -> Double {
        snapshot.buckets
            .filter { $0.kind == kind }
            .reduce(0) { partialResult, bucket in
                partialResult + bucket.amount
            }
    }
}
