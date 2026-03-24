//
//  BounceOption.swift
//  Mote
//
//  Created by 홍정연 on 3/24/26.
//

import CoreGraphics

enum BounceOption: String, CaseIterable {
    case calm
    case soft
    case lively
    
    static let `default`: BounceOption = .soft
    
    var title: String {
        switch self {
        case .calm:
            return "Calm"
        case .soft:
            return "Soft"
        case .lively:
            return "Lively"
        }
    }
    
    var restitution: CGFloat {
        switch self {
        case .calm:
            return 0.12
        case .soft:
            return 0.22
        case .lively:
            return 0.34
        }
    }
}
