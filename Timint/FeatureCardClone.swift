//
//  FeatureCardClone.swift
//  Timint
//
//  Created by Glen gu on 2026-03-21.
//

import SwiftUI

struct FeatureCardClone: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
    }
}

struct FeatureCardClone_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            FeatureCardClone(
                title: "Daily Log",
                subtitle: "Record where your time went",
                icon: "list.bullet.rectangle.fill",
                color: .green
            )
            .padding()
        }
    }
}
