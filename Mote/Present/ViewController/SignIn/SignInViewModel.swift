//
//  SignInViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel {
    
    private let disposeBag = DisposeBag()
    private let createProfileUseCase: CreateProfileUseCase
    
    private let fetchProfileUseCase: FetchProfileUseCase
    private let signOutUseCase: SignOutUseCase
    
    var onProfileCreated: ((String) -> Void)?
    
    let username = BehaviorRelay<String>(value: "")
    let createRequested = PublishRelay<Void>()
    let closeRequested = PublishRelay<Void>()
    let isLoading = BehaviorRelay<Bool>(value: false)
    let createFailed = PublishRelay<Error>()
    
    lazy var canCreate: Driver<Bool> = Driver
        .combineLatest(
            self.username.asDriver(),
            self.isLoading.asDriver()
        ) { username, isLoading in
            let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            return normalizedUsername.isEmpty == false && isLoading == false
        }
    
    init(
        createProfileUseCase: CreateProfileUseCase,
        fetchProfileUseCase: FetchProfileUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.createProfileUseCase = createProfileUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.signOutUseCase = signOutUseCase
        self.bind()
    }
    
    private func bind() {
        self.createRequested
            .withLatestFrom(Observable.combineLatest(
                self.username.asObservable(),
                self.isLoading.asObservable()
            ))
            .filter { _, isLoading in
                isLoading == false
            }
            .map { username, _ in
                username.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { username in
                username.isEmpty == false
            }
            .bind { [weak self] username in
                self?.createAndFetchProfile(username: username)
            }
            .disposed(by: self.disposeBag)
        
        self.closeRequested
            .bind { [weak self] _ in
                self?.signOut()
            }
            .disposed(by: self.disposeBag)
    }
    
    private func signOut() {
        do {
            try self.signOutUseCase.execute()
        } catch {
            self.createFailed.accept(error)
        }
    }
    
    private func createAndFetchProfile(username: String) {
        self.isLoading.accept(true)
        
        self.createProfileUseCase.execute(username: username) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchProfileAfterCreate(username: username)
                case .failure(let error):
                    self.isLoading.accept(false)
                    self.createFailed.accept(error)
                }
            }
        }
    }
    
    private func fetchProfileAfterCreate(username: String) {
        self.fetchProfileUseCase.execute { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading.accept(false)
                switch result {
                case .success(let profile):
                    guard let profile else {
                        self.createFailed.accept(SignInFlowError.missingProfile)
                        return
                    }
                    
                    let completedUsername = profile.username.isEmpty ? username : profile.username
                    ProfileSession.shared.update(profile: profile)
                    self.onProfileCreated?(completedUsername)
                case .failure(let error):
                    self.createFailed.accept(error)
                }
            }
        }
    }
}

private enum SignInFlowError: LocalizedError {
    case missingProfile
    
    var errorDescription: String? {
        switch self {
        case .missingProfile:
            return "프로필 조회 결과가 비어 있습니다."
        }
    }
}

