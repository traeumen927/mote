//
//  FetchGravityOptionUseCase.swift
//  Mote
//
//  Created by 홍정연 on 3/24/26.
//

import Foundation

final class FetchGravityOptionUseCase {

    private let motePreferencesRepository: MotePreferencesRepository

    init(motePreferencesRepository: MotePreferencesRepository) {
        self.motePreferencesRepository = motePreferencesRepository
    }

    func execute() -> GravityOption {
        self.motePreferencesRepository.fetchGravityOption()
    }
}
