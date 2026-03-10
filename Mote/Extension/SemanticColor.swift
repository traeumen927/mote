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
    case bgSelection
    case bgUnSelection

    // MARK: - Text
    case textPrimary
    case textSecondary
    case textDisabled
    case textSelected
    case textUnSelected

    // MARK: - Icon
    case iconPrimary
    case iconSecondary
    case iconTertiary
    case iconOnAccent
    case iconDestructive
    case iconTab

    // MARK: - Border
    case borderDefault
    case borderFocused
    case divider
    case borderAccent
    case borderDestructive
    case borderSelection

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
            
        case .bgSelection:
            return .palette(.MB20)
            
        case .bgUnSelection:
            return .palette(.MB10)


        // MARK: - Text

        case .textPrimary:
            return .palette(.I40)

        case .textSecondary:
            return .palette(.I30)

        case .textDisabled:
            return .palette(.I10)
            
        case .textSelected:
            return .palette(.CT20)
            
        case .textUnSelected:
            return .palette(.CT10)


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
            return .palette(.R10)

        case .borderFocused:
            return .palette(.R20)

        case .divider:
            return .palette(.N20)

        case .borderAccent:
            return .palette(.A40)

        case .borderDestructive:
            return .palette(.SR40)
            
        case .borderSelection:
            return .palette(.MB30)


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
