//
//  GraphData.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-07.
//

struct GraphData: Identifiable {
    var label: String
    var net: Double
    
    var id: String { label }
}
