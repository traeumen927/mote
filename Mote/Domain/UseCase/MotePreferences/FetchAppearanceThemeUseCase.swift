//
//  FetchAppearanceThemeUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/18/26.
//

import Foundation

final class FetchAppearanceThemeUseCase {

    private let motePreferencesRepository: MotePreferencesRepository

    init(motePreferencesRepository: MotePreferencesRepository) {
        self.motePreferencesRepository = motePreferencesRepository
    }

    func execute() -> AppearanceThemeOption {
        self.motePreferencesRepository.fetchAppearanceTheme()
    }
}
