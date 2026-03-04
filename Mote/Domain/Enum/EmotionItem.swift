//
//  EmotionItem.swift
//  Mote
//
//  Created by 홍정연 on 3/4/26.
//

import Foundation

enum EmotionItem: String, CaseIterable {
    case proud = "😎 Proud"
    case touched = "🥹 Touched"
    case furious = "🤬 Furious"
    case excited = "😝 Excited"
    case happy = "🥰 Happy"
    case okay = "🙂 Okay"
    case meh = "😐 Meh"
    case displeased = "☹️ Displeased"
    case sad = "😭 Sad"

    var displayText: String {
        self.rawValue
    }
}
