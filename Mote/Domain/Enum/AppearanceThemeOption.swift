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
            return "시스템 설정"
        case .light:
            return "라이트 모드"
        case .dark:
            return "다크 모드"
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
