//
//  UsernamePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-18.
//

import SwiftUI

struct ProfileNameSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (String, String) -> Void
    
    @State private var firstName: String
    @State private var lastName: String
    
    init(
        initialFirstName: String = "Jane",
        initialLastName: String = "Doe",
        onSave: @escaping (String, String) -> Void = { _, _ in}
    ) {
            self.onSave = onSave
            _firstName = State(initialValue: initialFirstName)
            _lastName = State(initialValue: initialLastName)
        }
    
    private var normalizedFirstName: String {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedLastName: String {
        lastName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var canSave: Bool {
        !(normalizedFirstName.isEmpty && normalizedLastName.isEmpty)
    }
    
    var body: some View {
        ZStack{
            PageBackground()
            
            ScrollView (showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack (spacing: 14){
                        DragIndicator()
                        
                        PageHeader(
                            eyebrow: "Name",
                            title: "Update your name",
                            subtitle: "Choose the first and last name Tempo shows in profile surfaces and account cards."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                    
                    SurfaceCard {
                        Text("Name Input")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("tempoInk").opacity(0.52))
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("tempoInk"))

                                TextField("First Name", text: $firstName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color("tempoInk"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color("tempoShell").opacity(0.75))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Name")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("tempoInk"))

                                TextField("Last Name", text: $lastName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color("tempoInk"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color("tempoShell").opacity(0.75))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }
                    }
                    
                    HStack {
                        ActionButton(
                            title: "Cancel",
                            action: dismiss.callAsFunction
                        )
                        ActionButton(
                            title: "Save Name",
                            action: saveName
                        )
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
        }
    }
    
    private func saveName() {
        
        guard canSave else {
            return
        }
        
        onSave(normalizedFirstName, normalizedLastName)
        dismiss()
    }
    
}

#Preview {
    ProfileNameSheet()
}
