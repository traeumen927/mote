//
//  DriftDetailViewModel.swift
//  Mote
//
//  Created by 홍정연 on 4/23/26.
//

import Foundation

final class DriftDetailViewModel {
    let emotion: String
    let dateText: String
    let captionText: String
    let isHidden: Bool

    init(record: EmotionRecord, dateFormatter: DateFormatter) {
        self.emotion = record.emotion

        if let createdAt = record.createdAt {
            self.dateText = "\(dateFormatter.string(from: createdAt))"
        } else {
            self.dateText = ""
        }

        self.captionText = record.caption.isEmpty ? "" : record.caption
        self.isHidden = record.isHidden
    }
}
