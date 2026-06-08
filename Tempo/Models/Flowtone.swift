//
//  Flowtone.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-06-07.
//

import Foundation
import SwiftUI

enum Flowtone {
    case positive
    case negative
    case neutral

    var tint: Color {
        switch self {
        case .positive:
            return .tempoLeaf
        case .negative:
            return .tempoLossRed
        case .neutral:
            return .tempoInk
        }
    }

    var background: Color {
        switch self {
        case .positive:
            return .tempoSoftMint.opacity(0.38)
        case .negative:
            return .tempoLossWash.opacity(0.5)
        case .neutral:
            return .tempoNeutralCard.opacity(0.50)
        }
    }
}


