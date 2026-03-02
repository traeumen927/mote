//
//  SemanticColor.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import Foundation
import UIKit

enum SemanticColor {

    // MARK: - Background
    case bgApp
    case bgSurface
    case bgElevated
    case bgGrouped
    case bgInteractive
    case bgInteractivePressed
    case bgDisabled
    case bgAccentSubtle

    // MARK: - Text
    case textPrimary
    case textSecondary
    case textTertiary
    case textDisabled
    case textOnAccent
    case textDestructive
    case textSuccess
    case textWarning

    // MARK: - Icon
    case iconPrimary
    case iconSecondary
    case iconTertiary
    case iconOnAccent
    case iconDestructive
    case iconTab

    // MARK: - Border
    case borderDefault
    case borderStrong
    case divider
    case borderAccent
    case borderDestructive

    // MARK: - Accent
    case accentPrimary
    case accentStrong
    case accentSoft
    case accentForeground

    // MARK: - Control
    case buttonPrimaryBackground
    case buttonPrimaryForeground
    case buttonSecondaryBackground
    case buttonSecondaryForeground
    case buttonDestructiveBackground
    case buttonDestructiveForeground
    case controlFill
    case controlFillPressed
}

extension SemanticColor {

    var uiColor: UIColor {
        switch self {

        // MARK: - Background

        case .bgApp:
            return .palette(.N10)

        case .bgSurface:
            return .palette(.N20)

        case .bgElevated:
            return .palette(.N30)

        case .bgGrouped:
            return .palette(.N10)

        case .bgInteractive:
            return .palette(.N20)

        case .bgInteractivePressed:
            return .palette(.N30)

        case .bgDisabled:
            return .palette(.N20)

        case .bgAccentSubtle:
            return .palette(.A20)


        // MARK: - Text

        case .textPrimary:
            return .palette(.I40)

        case .textSecondary:
            return .palette(.I30)

        case .textTertiary:
            return .palette(.I20)

        case .textDisabled:
            return .palette(.I10)

        case .textOnAccent:
            return .palette(.I40)

        case .textDestructive:
            return .palette(.SR40)

        case .textSuccess:
            return .palette(.SG40)

        case .textWarning:
            return .palette(.SY40)


        // MARK: - Icon

        case .iconPrimary:
            return .palette(.I40)

        case .iconSecondary:
            return .palette(.I30)

        case .iconTertiary:
            return .palette(.I20)

        case .iconOnAccent:
            return .palette(.I40)

        case .iconDestructive:
            return .palette(.SR40)
            
        case .iconTab:
            return .palette(.SS40)


        // MARK: - Border

        case .borderDefault:
            return .palette(.N30)

        case .borderStrong:
            return .palette(.N40)

        case .divider:
            return .palette(.N20)

        case .borderAccent:
            return .palette(.A40)

        case .borderDestructive:
            return .palette(.SR40)


        // MARK: - Accent

        case .accentPrimary:
            return .palette(.A40)

        case .accentStrong:
            return .palette(.A60)

        case .accentSoft:
            return .palette(.A20)

        case .accentForeground:
            return .palette(.I40)


        // MARK: - Control

        case .buttonPrimaryBackground:
            return .palette(.A40)

        case .buttonPrimaryForeground:
            return .palette(.I40)

        case .buttonSecondaryBackground:
            return .palette(.N20)

        case .buttonSecondaryForeground:
            return .palette(.I40)

        case .buttonDestructiveBackground:
            return .palette(.SR40)

        case .buttonDestructiveForeground:
            return .palette(.I40)

        case .controlFill:
            return .palette(.N20)

        case .controlFillPressed:
            return .palette(.N30)
        }
    }
}
