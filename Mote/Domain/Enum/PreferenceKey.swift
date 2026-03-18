//
//  PreferenceKey.swift
//  Mote
//
//  Created by 홍정연 on 3/18/26.
//

import Foundation

// MARK: UserDefault에 저장하는 대상키
enum PreferenceKey: String {
    case size
    case theme
    
    func userDefaultsKey(for uid: String) -> String {
        "mote.preferences.\(self.rawValue).\(uid)"
    }
}
