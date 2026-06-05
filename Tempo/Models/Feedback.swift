//
//  Feedback.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-05.
//

import Foundation

struct Feedback: Codable {
    let id: UUID?
    let date: Date
    let topic: String
    let information: String
}
