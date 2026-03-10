//
//  UIColor.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

// MARK: Resource/Assets/Color와 매칭되는 값
enum PaletteColor: String {
    // Accent
    case A20, A40, A60
    // Ink
    case I10, I20, I30, I40
    // Neutral
    case N10, N20, N30, N40, N50, R10, R20
    // State
    case SG20, SG30, SG40, SS40, SR40, SY40, MB10, MB20, MB30, CT10, CT20
}

extension UIColor {
    static func palette(_ token: PaletteColor) -> UIColor {
        guard let c = UIColor(named: token.rawValue) else {
            assertionFailure("Missing color asset: \(token.rawValue)")
            return .magenta
        }
        return c
    }
}
