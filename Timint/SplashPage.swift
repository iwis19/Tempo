//
//  SplashPage.swift
//  Timint
//
//  Created by Glen gu on 2026-03-21.
//

import SwiftUI

struct SplashPage: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.04, green: 0.12, blue: 0.10), Color(red: 0.07, green: 0.27, blue: 0.22), Color(red: 0.10, green: 0.42, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            Text("Timint")
                .foregroundStyle(.white)
                .font(.system(size: 42, weight: .bold, design: .rounded))
        }
        
        
        
        
        
    }
}

#Preview {
    SplashPage()
}
