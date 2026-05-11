//
//  ProfileDailyStatementGuidePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-20.
//

import SwiftUI

struct ProfileDailyStatementGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PageBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(spacing: 14) {
                        DragIndicator()

                        PageHeader(
                            eyebrow: "Daily Statements",
                            title: "See how Tempo builds the statement",
                            subtitle: "Each day, Tempo turns your logged time into a simple summary."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)

                    SurfaceCard {
                        SectionTitle(title: "How It Works")

                        StatementFlowStepRow(
                            number: "1",
                            title: "Log what happened",
                            bodyText: "Log your activities during the day."
                        )
                        StatementFlowStepRow(
                            number: "2",
                            title: "Sort the time",
                            bodyText: "Tempo places each activity in Earned, Required, or Spent."
                        )
                        StatementFlowStepRow(
                            number: "3",
                            title: "Apply your rate",
                            bodyText: "Your hourly rate turns that time into dollar value."
                        )
                        StatementFlowStepRow(
                            number: "4",
                            title: "Summarize the result",
                            bodyText: "Tempo adds it up and shows your daily result."
                        )
                    }

                    SurfaceCard {
                        SectionTitle(title: "What Each One Means")

                        PreviewRow(
                            title: "Earned",
                            value: "Value gained",
                            tint: Color("tempoLeaf")
                        )
                        PreviewRow(
                            title: "Required",
                            value: "Necessary cost",
                            tint: Color("tempoInk")
                        )
                        PreviewRow(
                            title: "Spent",
                            value: "Value lost",
                            tint: Color("tempoLossRed")
                        )
                    }

                    SurfaceCard {
                        SectionTitle(title: "Simple Goal")

                        Text("Aim for more Earned time, less Spent time, and a clear view of your Required time.")
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
    ProfileDailyStatementGuideSheet()
}
