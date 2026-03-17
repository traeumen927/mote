//
//  UpdateMoteSizeUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import Foundation

final class UpdateMoteSizeUseCase {

    private let motePreferencesRepository: MotePreferencesRepository

    init(motePreferencesRepository: MotePreferencesRepository) {
        self.motePreferencesRepository = motePreferencesRepository
    }

    func execute(_ size: MoteSizeOption) {
        self.motePreferencesRepository.updateMoteSize(size)
    }
}
