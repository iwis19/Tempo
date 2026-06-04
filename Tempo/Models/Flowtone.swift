//
//  Flowtone.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-26.
//

import SwiftUI

enum Flowtone {
    case positive
    case negative
    case neutral

    var tint: Color {
        switch self {
        case .positive:
            return Color("tempoLeaf")
        case .negative:
            return Color("tempoLossRed")
        case .neutral:
            return Color("tempoInk")
        }
    }

    var background: Color {
        switch self {
        case .positive:
            return Color("tempoSoftMint").opacity(0.38)
        case .negative:
            return Color("tempoLossWash").opacity(0.5)
        case .neutral:
            return Color("tempoNeutralCard").opacity(0.50)
        }
    }
}
