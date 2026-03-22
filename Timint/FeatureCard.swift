//
//  FeatureCard.swift
//  Timint
//
//  Created by Glen gu on 2026-03-21.
//

import SwiftUI

struct FeatureCard: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct FeatureCard_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCard()
    }
}
