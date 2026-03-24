//
//  UpdateGravityOptionUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/24/26.
//

import Foundation

final class UpdateGravityOptionUseCase {

    private let motePreferencesRepository: MotePreferencesRepository

    init(motePreferencesRepository: MotePreferencesRepository) {
        self.motePreferencesRepository = motePreferencesRepository
    }

    func execute(_ gravityOption: GravityOption) {
        self.motePreferencesRepository.updateGravityOption(gravityOption)
    }
}
