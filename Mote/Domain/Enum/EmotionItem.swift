//
//  EmotionItem.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation

enum EmotionItem: String, CaseIterable {
    case proud = "😎"
    case touched = "🥹"
    case furious = "🤬"
    case excited = "😝"
    case happy = "🥰"
    case okay = "🙂"
    case meh = "😐"
    case displeased = "☹️"
    case sad = "😭"
    
    var text: String {
        switch self {
        case .proud: "Proud"
        case .touched: "Touched"
        case .furious: "Furious"
        case .excited: "Excited"
        case .happy: "Happy"
        case .okay: "Okay"
        case .meh: "Meh"
        case .displeased: "Displeased"
        case .sad: "Sad"
        }
    }
    
    var displayText: String {
        "\(self.rawValue) \(self.text)"
    }
    
    static func index(matching storedEmotion: String) -> Int? {
        let normalizedEmotion = storedEmotion.split(separator: " ").first.map(String.init) ?? storedEmotion
        return Self.allCases.firstIndex {
            $0.rawValue == normalizedEmotion
        }
    }
}
