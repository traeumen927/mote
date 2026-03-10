//
//  ProfileRepository.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation

protocol ProfileRepository {
    func createProfile(
        request: CreateProfileRequest,
        completion: @escaping (Result<Profile, Error>) -> Void
    )
    
    func fetchProfile(
        request: FetchProfileRequest,
        completion: @escaping (Result<Profile?, Error>) -> Void
    )
}
