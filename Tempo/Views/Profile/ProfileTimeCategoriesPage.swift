//
//  ProfileTimeCategoriesPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-20.
//

import SwiftUI

struct ProfileTimeCategoriesPage: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PageBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(spacing: 14) {
                        DragIndicator()

                        PageHeader(
                            eyebrow: "Time Categories",
                            title: "Learn what belongs where",
                            subtitle: "Tempo puts your time into three groups: Earned, Required, and Spent."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)

                    TimeCategoryCard(
                        title: "Earned",
                        summary: "Time that helps you feel better, grow, or make progress.",
                        tint: Color("tempoLeaf"),
                        examples: [
                            "Focused work",
                            "Exercise or rest",
                            "Learning or practice",
                            "Good time with people you care about"
                        ]
                    )

                    TimeCategoryCard(
                        title: "Required",
                        summary: "Time you need to spend to keep life and work moving.",
                        tint: Color("tempoInk"),
                        examples: [
                            "Commutes",
                            "Chores or errands",
                            "Appointments",
                            "Work you need to do"
                        ]
                    )

                    TimeCategoryCard(
                        title: "Spent",
                        summary: "Time that uses energy or attention without giving much back.",
                        tint: Color("tempoLossRed"),
                        examples: [
                            "Mindless scrolling",
                            "Procrastination",
                            "Too much task switching",
                            "Time that felt wasted"
                        ]
                    )

                    SurfaceCard {
                        SectionTitle(title: "Simple Rule")

                        Text("Earned helps you. Required has to get done. Spent drains time or attention.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color("tempoInk").opacity(0.70))
                    }

                    ActionButton(
                        title: "Done",
                        action: dismiss.callAsFunction)
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
        }
    }

}

#Preview {
    ProfileTimeCategoriesPage()
}
