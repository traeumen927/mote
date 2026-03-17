//
//  FetchMoteSizeUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import Foundation

final class FetchMoteSizeUseCase {

    private let motePreferencesRepository: MotePreferencesRepository

    init(motePreferencesRepository: MotePreferencesRepository) {
        self.motePreferencesRepository = motePreferencesRepository
    }

    func execute() -> MoteSizeOption {
        self.motePreferencesRepository.fetchMoteSize()
    }
}
