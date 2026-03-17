//
//  MotePreferencesRepositoryImpl.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import Foundation

final class MotePreferencesRepositoryImpl: MotePreferencesRepository {

    private let userDefaults: UserDefaults
    private let uidProvider: CurrentUserUIDProviding

    init(
        userDefaults: UserDefaults = .standard,
        uidProvider: CurrentUserUIDProviding = ProfileSession.shared
    ) {
        self.userDefaults = userDefaults
        self.uidProvider = uidProvider
    }

    func fetchMoteSize() -> MoteSizeOption {
        guard let key = self.makePreferenceKey() else {
            return .default
        }

        guard let rawValue = self.userDefaults.string(forKey: key) else {
            return .default
        }

        return MoteSizeOption(rawValue: rawValue) ?? .default
    }

    func updateMoteSize(_ size: MoteSizeOption) {
        guard let key = self.makePreferenceKey() else { return }
        self.userDefaults.set(size.rawValue, forKey: key)
    }

    private func makePreferenceKey() -> String? {
        guard let uid = self.uidProvider.currentUID, uid.isEmpty == false else {
            return nil
        }

        return "mote.preferences.size.\(uid)"
    }
}
