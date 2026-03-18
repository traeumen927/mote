//
//  UpdateAppearanceThemeUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/18/26.
//

import Foundation

final class UpdateAppearanceThemeUseCase {

    private let motePreferencesRepository: MotePreferencesRepository

    init(motePreferencesRepository: MotePreferencesRepository) {
        self.motePreferencesRepository = motePreferencesRepository
    }

    func execute(_ theme: AppearanceThemeOption) {
        self.motePreferencesRepository.updateAppearanceTheme(theme)
    }
}
