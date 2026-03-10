//
//  ProfileSession.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation
import FirebaseAuth

protocol CurrentUserUIDProviding {
    var currentUID: String? { get }
}

final class ProfileSession: CurrentUserUIDProviding {
    static let shared = ProfileSession()

    private init() {}

    private let lock = NSLock()
    private var profile: Profile?

    var currentProfile: Profile? {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.profile
    }

    var currentUID: String? {
        if let profileUID = self.currentProfile?.uid {
            return profileUID
        }

        return Auth.auth().currentUser?.uid
    }

    func update(profile: Profile) {
        self.lock.lock()
        self.profile = profile
        self.lock.unlock()
    }

    func clear() {
        self.lock.lock()
        self.profile = nil
        self.lock.unlock()
    }
}
