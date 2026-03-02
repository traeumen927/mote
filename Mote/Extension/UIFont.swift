//
//  UIFont.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

extension UIFont {
    static func outfit(_ weight: AppFontWeight, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: weight.rawValue, size: size) else {
            fatalError("❌ Outfit font not found: \(weight.rawValue)")
        }
        return font
    }
}

enum AppFontWeight: String, CaseIterable {
    case thin = "Outfit-Thin"
    case extraLight = "Outfit-ExtraLight"
    case light = "Outfit-Light"
    case regular = "Outfit-Regular"
    case medium = "Outfit-Medium"
    case semiBold = "Outfit-SemiBold"
    case bold = "Outfit-Bold"
    case extraBold = "Outfit-ExtraBold"
    case black = "Outfit-Black"
}
