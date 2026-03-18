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
        self.fetchValue(for: .size, defaultValue: .default)
    }
    
    func updateMoteSize(_ size: MoteSizeOption) {
        self.storeValue(size, for: .size)
    }
    
    func fetchAppearanceTheme() -> AppearanceThemeOption {
        self.fetchValue(for: .theme, defaultValue: .default)
    }
    
    func updateAppearanceTheme(_ theme: AppearanceThemeOption) {
        self.storeValue(theme, for: .theme)
    }
    
    private func fetchValue<Value: RawRepresentable>(
        for key: PreferenceKey,
        defaultValue: Value
    ) -> Value where Value.RawValue == String {
        guard let userDefaultsKey = self.makePreferenceKey(for: key) else {
            return defaultValue
        }
        
        guard let rawValue = self.userDefaults.string(forKey: userDefaultsKey) else {
            return defaultValue
        }
        
        return Value(rawValue: rawValue) ?? defaultValue
    }
    
    private func storeValue<Value: RawRepresentable>(
        _ value: Value,
        for key: PreferenceKey
    ) where Value.RawValue == String {
        guard let userDefaultsKey = self.makePreferenceKey(for: key) else { return }
        self.userDefaults.set(value.rawValue, forKey: userDefaultsKey)
    }
    
    private func makePreferenceKey(for key: PreferenceKey) -> String? {
        guard let uid = self.uidProvider.currentUID, uid.isEmpty == false else {
            return nil
        }
        
        return key.userDefaultsKey(for: uid)
    }
}
