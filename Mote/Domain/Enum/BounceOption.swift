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
    
    /// 충돌 시 얼마나 튀는지 (0.0 ~ 1.0, 0: 안 튐 / 1: 완전 탄성)
    var restitution: CGFloat {
        switch self {
        case .calm:
            return 0.16
        case .soft:
            return 0.34
        case .lively:
            return 0.8
        }
    }
    
    /// 표면과의 마찰 정도 (0.0 ~ 1.0, 0: 미끄러짐 / 1: 잘 붙음)
    var friction: CGFloat {
        switch self {
        case .calm:
            return 0.88
        case .soft:
            return 0.6
        case .lively:
            return 0.3
        }
    }
    
    /// 이동 속도가 얼마나 빨리 감소하는지 (0.0 ~ ∞, 보통 0 ~ 1 사용, 높을수록 빨리 멈춤)
    var linearDamping: CGFloat {
        switch self {
        case .calm:
            return 0.9
        case .soft:
            return 0.54
        case .lively:
            return 0.22
        }
    }
    
    /// 회전 속도가 얼마나 빨리 감소하는지 (0.0 ~ ∞, 보통 0 ~ 1 사용, 높을수록 회전 빨리 멈춤)
    var angularDamping: CGFloat {
        switch self {
        case .calm:
            return 1.15
        case .soft:
            return 0.85
        case .lively:
            return 0.3
        }
    }
}
