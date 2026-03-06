//
//  AuthSession.swift
//  Mote
//
//  Created by 홍정연 on 3/6/26.
//

import Foundation
import FirebaseAuth

protocol CurrentUserUIDProviding {
    var currentUID: String? { get }
}

final class FirebaseAuthSession: CurrentUserUIDProviding {
    static let shared = FirebaseAuthSession()

    private init() {}

    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }
}
