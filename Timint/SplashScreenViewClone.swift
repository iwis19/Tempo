//
//  SplashScreenViewClone.swift
//  Timint
//
//  Created by Glen gu on 2026-03-21.
//

import SwiftUI

struct SplashScreenViewClone: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.12, blue: 0.10),
                    Color(red: 0.07, green: 0.27, blue: 0.22),
                    Color(red: 0.10, green: 0.42, blue: 0.34)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 130, height: 130)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(.white)

                            Text("Your Logo")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 8)

                Text("Timint")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Track your time like money.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.95))

                Text("Log your hours, review your balance, and see where your time is really going.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.horizontal, 30)

                BalanceCardClone()
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    FeatureCardClone(
                        title: "Daily Log",
                        subtitle: "Record where your time went",
                        icon: "list.bullet.rectangle.fill",
                        color: Color(red: 0.71, green: 0.94, blue: 0.82)
                    )

                    FeatureCardClone(
                        title: "Time Balance",
                        subtitle: "See gains and losses clearly",
                        icon: "chart.line.uptrend.xyaxis",
                        color: Color(red: 0.98, green: 0.86, blue: 0.49)
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding()
        }
    }
}

struct BalanceCardClone: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TODAY'S BALANCE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.72))

            Text("6h 45m")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Spent with intention")
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.78, green: 0.95, blue: 0.86))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
    }
}

struct SplashScreenViewClone_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenViewClone()
    }
}
