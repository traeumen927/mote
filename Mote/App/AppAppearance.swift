//
//  AppAppearance.swift
//  Mote
//
//  Created by 홍정연 on 3/18/26.
//

import UIKit

enum AppAppearance {
    static func apply(theme: AppearanceThemeOption, to window: UIWindow?) {
        window?.overrideUserInterfaceStyle = theme.interfaceStyle
    }
}
