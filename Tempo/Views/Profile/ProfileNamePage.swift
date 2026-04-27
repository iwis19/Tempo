//
//  UsernamePage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-18.
//

import SwiftUI

struct ProfileNamePage: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (String, String) -> Void
    
    @State private var firstName: String
    @State private var lastName: String
    
    init(
        initialFirstName: String,
        initialLastName: String,
        onSave: @escaping (String, String) -> Void
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
    
    private var displayName: String {
        let fullname = "\(normalizedFirstName) \(normalizedLastName)".trimmingCharacters(in: .whitespaces)
        return fullname
    }

    private var displayInitials: String {
        let firstInitial = normalizedFirstName.first.map(String.init) ?? ""
        let lastInitial = normalizedLastName.first.map(String.init) ?? ""
        let initials = firstInitial + lastInitial
        return initials
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
                        
                        Text("Keep the name recognizable so your account card feels personal and clear.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("tempoInk").opacity(0.60))
                    }
                    
                    SurfaceCard {
                        SectionTitle(title: "Preview")
                        
                        PreviewRow(
                            title: "Display Name",
                            value: displayName,
                            tint: Color("tempoInk")
                        )
                        
                        PreviewRow(
                            title: "Profile Initials",
                            value: displayInitials,
                            tint: Color("tempoInk")
                        )
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
    ProfileNamePage(
        initialFirstName: "Ronnie",
        initialLastName: "Gu",
        onSave: { firstName, lastName in
                    print(firstName, lastName)
                }
    )
}
