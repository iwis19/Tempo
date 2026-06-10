//
//  LaunchPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-03-21.
//

import SwiftUI
import Combine

struct LaunchPage: View {
    
    private let mainFontSize: CGFloat = 44
    private let subtitleFontSize: CGFloat = 20
    private let subtitleOpacity: Double = 0.92
    
    @State private var signInViewModel = SignInViewModel()
    
    @Binding var appUser: AppUser?
    
    @State private var fullSplash = false
    @State private var signInErrorMessage: String?
    
    private let subtitleEnding = [
        "seconds.",
        "minutes.",
        "hours.",
        "days.",
        "weeks.",
        "months.",
        "years."
    ]
    
    private var currentSubtitleEnding: String {subtitleEnding[currentSubtitleIndex]}
    
    @State private var currentSubtitleIndex = 0
    
    private let subtitleTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    private var subtitleTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    
    var body: some View {
        PageContainer{
            
            // logo, title, subtitles
            VStack(spacing: 0) {
                appLogo
                    .offset(y: 20)
                appTitle
                appSubtitle
                    .offset(y: -15)
                if fullSplash {
                    VStack (spacing: 7){
                        signInWithGoogle
                        signInWithApple
                        signInError
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 190)
            .padding(.horizontal, 20)
            .offset(y: -20)
        }
        // rotating subtitle text
        .onReceive(subtitleTimer) { _ in
            withAnimation(.easeIn(duration: 0.45)) {
                currentSubtitleIndex = (currentSubtitleIndex + 1) % subtitleEnding.count
            }
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
                .foregroundStyle(.tempoNeutralCard.opacity(0.37))
                .blur(radius:1.5)
            
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width:140, height:140)
                .offset(y:3)
            
            RoundedRectangle(cornerRadius: 28)
                .stroke(.tempoNeutralCard.opacity(fullSplash ? 0.4 : 0), lineWidth: 1.5)
                .frame(width:141, height:141)
                .shadow(radius: fullSplash ? 3 : 0)
        }
        .offset(y: fullSplash ? -35 : 120)
    }
    
    private var appTitle: some View {
        Text("Tempo")
            .foregroundStyle(.tempoInk.opacity(fullSplash ? 1 : 0))
            .font(.custom("Syne-Regular", size: mainFontSize))
            .padding(.top, 60)
            .padding(.bottom, 25)
            .offset(y:-37)
    }
    
    private var appSubtitle: some View {
        // rotating text
        HStack(spacing: 0) {
            Text("Earn your ")
                .foregroundStyle(.tempoInk.opacity(fullSplash ? subtitleOpacity : 0))
                .font(.system(size: subtitleFontSize, weight: .medium))
            
            Text(currentSubtitleEnding)
                .id(currentSubtitleIndex)
                .foregroundStyle(.tempoInk.opacity(fullSplash ? subtitleOpacity : 0))
                .font(.system(size: subtitleFontSize, weight: .medium))
                .transition(subtitleTransition)
        }
        .frame(maxWidth: 260)
        .offset(y:-40)
    }
    
    private var signInWithGoogle: some View {
        
        Button(
            action: {
                Task {
                    do {
                        let appUser = try await signInViewModel.signInWithGoogle()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            self.appUser = appUser
                        }
                    } catch {
                        let message = error.localizedDescription
                        signInErrorMessage = message
                        print("Google sign-in failed: \(message)")
                        print(String(reflecting: error))
                    }
                }
            }
        ){
            HStack (spacing: 0){
                Text("Sign in with Google")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.leading, 10)
                
                Image("GoogleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .padding(.vertical)
            .padding(.horizontal, 15)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.tempoInk)
            )
        }
        
    }
    
    private var signInWithApple: some View {
        Button(
            action: {
                Task {
                    do {
                        let appUser = try await signInViewModel.signInWithApple()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            self.appUser = appUser
                        }
                    } catch{
                        let message = error.localizedDescription
                        signInErrorMessage = message
                        print("Apple sign-in failed: \(message)")
                        print(String(reflecting: error))
                    }
                }
            }
        ){
            HStack (spacing: 7){
                Text("Sign in with Apple")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.leading, 10)
                
                Image("AppleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .offset(y: -1.5)
            }
            .padding(.vertical)
            .padding(.horizontal, 15)
            .frame(width: 220, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.tempoInk)
            )
        }
    }
    
    private var signInError: some View {
        Group {
            if let signInErrorMessage {
                Text(signInErrorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.tempoLossRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 14)
            }
        }
    }
}


#Preview{
    LaunchPage(
       appUser: .constant(AppUser(id: "1", email: "ronniegu2019@gmail.com"))
    )
}
