//
//  MotePreferencesRepository.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import Foundation

protocol MotePreferencesRepository {
    func fetchMoteSize() -> MoteSizeOption
    func updateMoteSize(_ size: MoteSizeOption)
}
