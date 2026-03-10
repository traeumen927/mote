//
//  ProfileDTO.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation
import FirebaseFirestore

struct ProfileDTO {
    let username: String
    let createAt: Date
    let lastActiveAt: Date

    init(data: [String: Any]) {
        self.username = data["username"] as? String ?? ""
        self.createAt = Self.parseDate(data["createAt"]) ?? Date()
        self.lastActiveAt = Self.parseDate(data["lastActiveAt"]) ?? self.createAt
    }

    func toDomain() -> Profile {
        Profile(
            username: self.username,
            createAt: self.createAt,
            lastActiveAt: self.lastActiveAt
        )
    }

    private static func parseDate(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = value as? Date {
            return date
        }

        return nil
    }
}
