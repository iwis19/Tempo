//
//  StyleTemplates.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-16.
//

import SwiftUI

struct StyleTemplates: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


// PAGE CONTAINERS
// <Content: View> indicates that it is generic over some content, but content must also follow View protocol, meaning that this container can hold any child UI inside it
struct PageContainer <Content: View>: View {
    let bottomInset: CGFloat // how much space is added at the bottom, CGFloat is meant for UI / drawing floating-point number
    let content: Content // page-specific UI i pass in
    
    // @ViewBuilder lets me write multiple UI views naturally inside this container call, content() stores the resulting view
    init(bottomInset: CGFloat = 170, @ViewBuilder content: () -> Content) {
        self.bottomInset = bottomInset
        self.content = content()
    }
    
    var body: some View{
        ZStack {
            PageBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, bottomInset)
                .offset(y: -20)
            }
        }
    }
}

struct MainCard <Content: View>: View{
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack{
            content
        }
        .padding(22) // add inner space around the view's content by 22 px, rather than all view elements in the stack
        .background(
            LinearGradient(
                colors: [Color("tempoDeepGreen"), Color("tempoLeaf")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous)) // cuts the entire View into a roundedrectangle
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        } // creates a subtle outline for this roundedrectangle
        .shadow(color: Color("tempoShadow").opacity(0.18), radius: 22, y: 12) // adds a shadow around the shape
    }
}


// PAGE BACKGROUNDS
struct PageBackground: View {
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
        .ignoresSafeArea()
    }
}


// PAGE HEADERS
struct Header: View {
    let eyebrow: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Text(eyebrow)
                .foregroundStyle(Color("tempoInk").opacity(0.58))
                .font(.system(size: 14, weight: .semibold))
            
            Text(title)
                .foregroundStyle(Color("tempoInk"))
                .font(.custom("Syne-Regular", size:34))
            // if userName is too long, it caps this entire line to max 2 lines, and uses ... to replace the exceeding characters
                .lineLimit(2)
                .truncationMode(.tail)
            
            // similar to python's "if subtitle:", it checks if value equals to nil or not, if not, it unwraps it, but it is a safer method than doing it normally
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("tempoInk").opacity(0.68))
            }
        }
    }
}
