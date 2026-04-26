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
    
    @State private var firstname: String
    @State private var lastname: String
    
    init(
        initialFirstname: String = "Test",
        initialLastname: String = "Preview",
        onSave: @escaping (String, String) -> Void = {_, _ in}
    ) {
            self.onSave = onSave
            _firstname = State(initialValue: initialFirstname)
            _lastname = State(initialValue: initialLastname)
        }
    
    private var normalizedFirstname: String {
        firstname.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedLastname: String {
        lastname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var displayName: String {
        let fullname = "\(normalizedFirstname) \(normalizedLastname)".trimmingCharacters(in: .whitespaces)
        return fullname
    }

    private var displayInitials: String {
        let firstInitial = normalizedFirstname.first.map(String.init) ?? ""
        let lastInitial = normalizedLastname.first.map(String.init) ?? ""
        let initials = firstInitial + lastInitial
        return initials
    }

    private var canSave: Bool {
        !(normalizedFirstname.isEmpty && normalizedLastname.isEmpty)
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
                    
                    SettingsContainer {
                        Text("Name Input")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("tempoInk").opacity(0.52))
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("tempoInk"))

                                TextField("First Name", text: $firstname)
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

                                TextField("Last Name", text: $lastname)
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
                    
                    SettingsContainer {
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
        
        onSave(normalizedFirstname, normalizedLastname)
        dismiss()
    }
    
}

#Preview {
    ProfileNamePage()

}
