//
//  MoteSizeOption.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import Foundation

enum MoteSizeOption: String, CaseIterable {
    case small
    case medium
    case large
    
    static let `default`: MoteSizeOption = .medium
    
    var title: String {
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small:
            38
        case .medium:
            50
        case .large:
            62
        }
    }
}
