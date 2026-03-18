//
//  AppearanceThemeOption.swift
//  Mote
//
//  Created by 홍정연 on 3/18/26.
//

import UIKit

enum AppearanceThemeOption: String, CaseIterable {
    case system
    case light
    case dark

    static let `default`: AppearanceThemeOption = .system

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
