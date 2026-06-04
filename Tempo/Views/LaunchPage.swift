//
//  LaunchPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-21.
//

import SwiftUI

struct LaunchPage: View {
    
    private let mainFontSize: CGFloat = 44
    private let subtitleFontSize: CGFloat = 20
    private let subtitleOpacity: Double = 0.92
    
    @State private var fullSplash = false
    
    private let subtitleEnding = [
        "seconds.",
        "minutes.",
        "hours.",
        "days.",
        "weeks.",
        "months.",
        "years."
    ]
    
    private let subtitleIndex: Int = Int.random(in: 0...6)
    
    var body: some View {
        ZStack {
            LaunchBackground(fullSplash: fullSplash)
            
            // logo, title, subtitles
            VStack(spacing: 0) {
                appLogo
                appTitle
                appSubtitle
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 190)
        }
        // waits 0.5s, then shows the app name and app subtitle
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.9)){
                    fullSplash = true
                }
            }
        }
    }
    
    private var appLogo: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 28)
                .frame(width:140, height:140)
                .foregroundStyle(.white.opacity(0.17))
                .blur(radius:1.5)
            
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width:140, height:140)
                .offset(y:3)  //fix logo misalignment in transluscent box
            
            RoundedRectangle(cornerRadius: 28)
                .stroke(.white.opacity(0.4), lineWidth: 1.5)
                .frame(width:141, height:141)
                .shadow(radius: 5)
        }
        .offset(y: fullSplash ? -35 : 120)
    }
    
    private var appTitle: some View {
        Text("Tempo")
            .foregroundStyle(.white.opacity(fullSplash ? 1 : 0))
            .font(.custom("Syne-Regular", size: mainFontSize))
            .padding(.top, 60)
            .padding(.bottom, 25)
            .offset(y:-37)
    }
    
    private var appSubtitle: some View {
        // rotating text
        HStack(spacing: 0) {
            Text("Earn your ")
                .foregroundStyle(.white.opacity(fullSplash ? subtitleOpacity : 0))
                .font(.system(size: subtitleFontSize, weight: .medium))
            
            Text(subtitleEnding[subtitleIndex])
                .foregroundStyle(.white.opacity(fullSplash ? subtitleOpacity : 0))
                .font(.system(size: subtitleFontSize, weight: .medium))
        }
        .frame(maxWidth: 260)
        .offset(y:-40)
    }
}


private struct LaunchBackground : View {
    let fullSplash: Bool

    var body : some View {
        //background gradient color
        LinearGradient(colors: [Color("tempoLeaf"), Color("tempoDeepGreen")], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        //miscellaneous shapes
        ZStack {
            RoundedRectangle(cornerRadius: 56)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red:1, green:1, blue:1).opacity(fullSplash ? 0.13 : 0),
                            Color(red: 0.81, green: 0.95, blue: 0.82).opacity(fullSplash ? 0.42 : 0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 230, height: 340)
                .rotationEffect(.degrees(-24))
                .offset(x: 155, y: -205)

            Circle()
                .fill(
                    LinearGradient(colors: [Color(red:1,green:1,blue:1).opacity(fullSplash ? 0.05 : 0), Color(red:0.97, green:1, blue:0.95).opacity(fullSplash ? 0.13 : 0)], startPoint: .top, endPoint: .bottom)
                )
                .blur(radius: 4)
                .frame(width: 170, height: 170)
                .offset(x: 120, y: -30)

            RoundedRectangle(cornerRadius: 48)
                .fill(Color(red: 0.8, green: 0.8, blue: 0.8).opacity(fullSplash ? 0.08 : 0))
                .frame(width: 175, height: 245)
                .rotationEffect(.degrees(34))
                .offset(x: -165, y: 120)

            RoundedRectangle(cornerRadius: 64)
                .fill(
                    LinearGradient(colors: [Color(red: 0.97, green: 1.00, blue: 0.94).opacity(fullSplash ? 0.11 : 0), Color(red:1,green:1,blue:1).opacity(fullSplash ? 0.03 : 0)],startPoint: .top,endPoint: .bottom)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(18))
                .offset(x: 145, y: 335)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview{
    LaunchPage()
}
