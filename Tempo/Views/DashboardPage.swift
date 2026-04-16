//
//  DashboardPage.swift
//  Tempo
//
//  Created by Glen gu on 2026-03-25.
//

import SwiftUI

struct DashboardPage: View {
    var body: some View {
        
        ZStack{
            DashboardBackground()
            
            // allows users to scroll down to see all content, with the scroll bar on the side hidden
            ScrollView (showsIndicators: false){
                VStack{
                    header
                    statementCard
                }
            }
            
        }
        
        
    }
    
    // 
    private var header: some View {
        
        VStack (alignment: .leading, spacing: 10){
            Text("Time Account")
                .foregroundStyle(Color("tempoInk").opacity(0.58))
                .font(.system(size: 14, weight: .semibold))
            
            // PLACEHOLDER FOR ACTUAL USERNAME
            Text("\(greetingText), userName")
                .foregroundStyle(Color("tempoInk"))
                .font(.custom("Syne-Regular", size:34))
                // if userName is too long, it caps this entire line to max 2 lines, and uses ... to replace the exceeding characters
                .lineLimit(2)
                .truncationMode(.tail)
        }
    }

    private var statementCard: some View {
        
        VStack{
            HStack{
                VStack{
                    Text("TODAY'S NET")
                        .font(.system(size:12, weight:.bold))
                        .tracking(1.2)
                        .foregroundStyle(Color.white.opacity(0.72))
                    
                    Text("AMOUNT MADE")
                        .font(.custom("Syne-Regular", size:46))
                        .foregroundStyle(Color.white)
                    
                    
                }
            }
        }
    }
    
    private var statementSummaryText: some view {
        
    }
    
    private var greetingText: String {
        // takes the hour from the user's local time
        let hour = Calendar.current.component(.hour, from: Date())
        
        // this is the switch statement syntax in swift
        switch hour {
            case 0..<12: return "Good morning"
            case 12..<18: return "Good afternoon"
            case 18...: return "Good evening"
            default: return "Hello"
        }
    }
}

private struct DashboardBackground : View {
    var body: some View{
        
        ZStack {
            LinearGradient(colors: [Color("tempoShell"), Color("tempoShell"), Color.white], startPoint: .topTrailing, endPoint: .bottomLeading)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color("tempoSoftMint").opacity(0.74))
                .blur(radius: 70)
                .frame(width: 260, height: 260)
                .offset(x: 145, y: -250)
            
            RoundedRectangle(cornerRadius: 70, style: .continuous)
                .fill(Color.white.opacity(0.58))
                .frame(width: 260, height: 340)
                .rotationEffect(.degrees(24))
                .offset(x: 165, y: -140)
            
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .stroke(Color("tempoLeaf").opacity(0.16), lineWidth: 1)
                .frame(width: 210, height: 210)
                .rotationEffect(.degrees(-18))
                .offset(x: -165, y: 290)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    DashboardPage()
}
