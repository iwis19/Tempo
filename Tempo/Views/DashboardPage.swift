//
//  DashboardPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-25.
//

import SwiftUI

struct DashboardPage: View {
    var body: some View {
        PageContainer {
            // TODO: ronnie is just a placeholder for now, after i collect first name from the actual user, it will be changed
            Header(eyebrow: "Time Account", title: "\(greetingText), Ronnie", subtitle: nil)
            statementCard
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
    
//    private var statementSummaryText: some view {
//        
//    }
    
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

#Preview {
    DashboardPage()
}
