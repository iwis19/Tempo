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

    var amountColor: Color {
        switch self {
        case .positive:
            return Color("tempoLeaf")
        case .negative:
            return Color("tempoLossRed")
        case .neutral:
            return Color("tempoInk")
        }
    }

    var iconName: String {
        switch self {
        case .positive:
            return "arrow.up.right"
        case .negative:
            return "arrow.down.right"
        case .neutral:
            return "equal"
        }
    }

    var badgeBackground: Color {
        switch self {
        case .positive:
            return Color("tempoSoftMint").opacity(0.38)
        case .negative:
            return Color("tempoLossWash")
        case .neutral:
            return Color("tempoSoftMint").opacity(0.20)
        }
    }
}
