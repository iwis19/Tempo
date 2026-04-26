//
//  TransactionItem.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-26.
//

import Foundation

struct TransactionItem: Identifiable {
    
    let id: UUID
    let title: String
    let duration: String
    let category: String
    let amount: String
    let tone: Flowtone
    
    init(
        id: UUID = UUID(),
        title: String,
        duration: String,
        category: String,
        amount: String,
        tone: Flowtone
    ){
        self.id = id
        self.title = title
        self.duration = duration
        self.category = category
        self.amount = amount
        self.tone = tone
    }
    
}
