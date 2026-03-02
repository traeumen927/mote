//
//  Typography.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit

enum Typography {

    // MARK: - Title
    static let largeTitle = UIFont.outfit(.thin, size: 32)
    static let title1 = UIFont.outfit(.light, size: 24)
    static let title2 = UIFont.outfit(.regular, size: 20)

    // MARK: - Body
    static let bodyLarge = UIFont.outfit(.regular, size: 17)
    static let body = UIFont.outfit(.regular, size: 15)
    static let bodySmall = UIFont.outfit(.light, size: 13)

    // MARK: - Button
    static let button = UIFont.outfit(.medium, size: 15)

    // MARK: - Caption
    static let caption = UIFont.outfit(.light, size: 12)

    // MARK: - Emphasis
    static let emphasis = UIFont.outfit(.semiBold, size: 15)
    static let heavy = UIFont.outfit(.bold, size: 18)
}
