//
//  ProfileFeedbackPage.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-20.
//

import SwiftUI

// TODO: MAKE DATABASE FOR FEEDBACK (PREFERABLY FIREBASE/MONGODB)
struct ProfileFeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var feedbackTopic = "General"
    @State private var feedbackMessage = ""

    private let topics = ["General", "Bug", "Idea", "Friction"]

    private var normalizedMessage: String {
        feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSend: Bool {
        !normalizedMessage.isEmpty
    }

    var body: some View {
        ZStack {
            PageBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(spacing: 14) {
                        DragIndicator()

                        PageHeader(
                            eyebrow: "Feedback",
                            title: "Tell Tempo what needs work",
                            subtitle: "Capture bugs, rough edges, or ideas so the product can keep getting sharper."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)

                    SurfaceCard {
                        Text("Feedback Draft")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("tempoInk").opacity(0.52))

                        // allows users to pick a value out of a list, and set it to a variable
                        Picker("Topic", selection: $feedbackTopic) {
                            // id: \.self means that Swift is using each string itself to be their own unique ID
                            ForEach(topics, id: \.self) { topic in
                                // if this value is chosen, send this value to feedbackTopic and set it as that
                                Text(topic).tag(topic)
                            }
                        }
                        .pickerStyle(.segmented)

                        ZStack(alignment: .topLeading) {
                            if feedbackMessage.isEmpty {
                                Text("Tell Tempo what felt confusing, slow, broken, or worth building next.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color("tempoInk").opacity(0.35))
                                    .padding(.horizontal, 18)
                                    .padding(.top, 18)
                            }
                            
                            // TextField vs. TextEditor: texteditor is for longer pieces of text, often multiline, while textfield is just a shorter input
                            TextEditor(text: $feedbackMessage)
                                .scrollContentBackground(.hidden)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color("tempoInk"))
                                .frame(minHeight: 150)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("tempoShell").opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }

                    HStack(spacing: 12) {
                        ActionButton(
                            title: "Cancel",
                            action: dismiss.callAsFunction
                        )
                        ActionButton(
                            title: "Send Feedback",
                            action: sendFeedback
                        )
                            .disabled(!canSend)
                            .opacity(canSend ? 1 : 0.55)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
        }
    }

    private func sendFeedback() {
        guard canSend else {
            return
        }

        dismiss()
    }
}

#Preview {
    ProfileFeedbackSheet()
}
