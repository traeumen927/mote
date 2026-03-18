//
//  AppAppearance.swift
//  Mote
//
//  Created by 홍정연 on 3/18/26.
//

import UIKit

enum AppAppearance {
    static func apply(theme: AppearanceThemeOption, to window: UIWindow?) {
        guard let window else { return }

        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve]
        ) {
            window.overrideUserInterfaceStyle = theme.interfaceStyle
            window.rootViewController?.view.setNeedsLayout()
            window.rootViewController?.view.layoutIfNeeded()
        }
    }
}
