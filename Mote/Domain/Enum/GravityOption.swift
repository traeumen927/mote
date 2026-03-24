//
//  GravityOption.swift
//  Mote
//
//  Created by 홍정연 on 3/24/26.
//

import CoreGraphics

/// Drift/Motes 장면의 중력 프리셋.
/// 실제 천체의 중력가속도 비율을 기준으로 Earth(9.81m/s²)를
/// 기존 기본값(-3.8)과 맞춰 스케일링한다.
enum GravityOption: String, CaseIterable {
    case moon
    case earth
    case saturn

    static let `default`: GravityOption = .earth

    var title: String {
        switch self {
        case .moon:
            return "🌕 Moon"
        case .earth:
            return "🌏 Earth"
        case .saturn:
            return "🪐 Saturn"
        }
    }

    var gravityVector: CGVector {
        switch self {
        case .moon:
            return CGVector(dx: 0, dy: -0.63)
        case .earth:
            return CGVector(dx: 0, dy: -3.8)
        case .saturn:
            return CGVector(dx: 0, dy: -9.6)
        }
    }
}
