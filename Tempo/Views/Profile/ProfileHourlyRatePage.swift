//
//  ProfileHourlyRatePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-17.
//

import SwiftUI

struct ProfileHourlyRatePage : View {
    
    // SwiftUI has a built in dismiss action from the environment, this ensures that if a view is presented somehow, there is a tool to close it
    @Environment(\.dismiss) private var dismiss
    
    // this is a closure property, this view expects to be given a function that takes a double and returns nothing, and then this view returns a saved hourly rate back to profilepage
    let onSave: (Double) -> Void
    
    @State private var hourlyRate: String
    
    // sets up view when it is created, gives it a starting default hourly rate, stores what to do when save is pressed
    init(
        initialHourlyRate: Double = 17.95,
        onSave: @escaping (Double) -> Void = { _ in}
    ){
        // "self" means this object, which e.g. self.hourlyRate,
        // "Self" means this type, which e.g. Self.formatted(...)
        self.onSave = onSave
        
        // because hourlyRate is @State, I cant initialize it with normal assignment, so i have to initialize the wrapper itself, which is _hourlyRate
        _hourlyRate = State(initialValue: RateFormatter.string(initialHourlyRate))
    }
    
    // converts the String hourlyRate into a Double, which spaces and newlines trimmed, "Double?" means it could return a Double OR nil
    private var parsedHourlyRate : Double? {
        Double(hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // if parsedHourlyRate's parsing succeeds, we take the value, if not, we use 0, hence this function FORCES a Double type output
    private var rateValue : Double {
        parsedHourlyRate ?? 0
    }
    
    // checks whether or not we can save, it tries to unwrap parsedHourlyRate first, but if its nil, it returns false, otherwise only allow if it is greater than 0
    private var canSave: Bool {
        
        //guard checks if a condition is false, if it is, immediately run else and exit
        // in "guard let", let tries to create a safe, unwrapped version of this optional, if it cant, then its probably invalid
        guard let parsedHourlyRate else {
            return false
        }
        return parsedHourlyRate > 0
    }
    
    var body : some View{
        ZStack {
            PageBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(spacing: 14) {
                        DragIndicator()

                        PageHeader(
                            eyebrow: "Hourly Rate",
                            title: "Update your time value",
                            subtitle: "Tempo uses this rate to translate time movement into a daily statement."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)

                    SurfaceCard {
                        Text("Rate Input")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("tempoInk").opacity(0.52))

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("$")
                                .font(.custom("Syne-Regular", size: 34))
                                .foregroundStyle(Color("tempoDeepGreen"))

                            TextField("20", text: $hourlyRate)
                                .keyboardType(.decimalPad)
                                .font(.custom("Syne-Regular", size: 42))
                                .foregroundStyle(Color("tempoInk"))

                            Text("/ hour")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color("tempoInk").opacity(0.60))
                        }

                        Text("Tempo will use it across checkups, history, and statement previews.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("tempoInk").opacity(0.60))
                    }

                    SurfaceCard {
                        SectionTitle(title: "Preview")

                        VStack(spacing: 12) {
                            PreviewRow(
                                title: "1h Earned",
                                value: "+\(CurrencyFormatter.string(rateValue))",
                                tint: Color("tempoLeaf")
                            )
                            PreviewRow(
                                title: "1h Required",
                                value: "-\(CurrencyFormatter.string(rateValue * 0.4))",
                                tint: Color("tempoLossRed")
                            )
                            PreviewRow(
                                title: "1h Spent",
                                value: "-\(CurrencyFormatter.string(rateValue))",
                                tint: Color("tempoLossRed")
                            )
                        }
                    }

                    HStack(spacing: 12) {
                        
                        // since we already have environment var dismiss set up, this is the same as passing dismiss()
                        ActionButton(
                            title: "Cancel",
                            action: dismiss.callAsFunction
                        )
                        
                        // passes the function saveRate in
                        ActionButton(
                            title: "Save Rate",
                            action: saveRate
                        )
                            // modifies if the button can be tapped or not
                            .disabled(!canSave)
                            .opacity(canSave ? 1 : 0.55)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
        }
    }
    
    private func saveRate() {
        guard let parsedHourlyRate, parsedHourlyRate > 0 else {
            return
        }
        
        onSave(parsedHourlyRate)
        dismiss()
    }
}


#Preview {
    ProfileHourlyRatePage()
}
