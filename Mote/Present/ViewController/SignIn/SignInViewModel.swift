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
    
    var onProfileCreated: (() -> Void)?
    
    let username = BehaviorRelay<String>(value: "")
    let createRequested = PublishRelay<Void>()
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
    
    init(createProfileUseCase: CreateProfileUseCase) {
        self.createProfileUseCase = createProfileUseCase
        self.bind()
    }
    
    private func bind() {
        self.createRequested
            .withLatestFrom(Observable.combineLatest(self.username.asObservable(), self.isLoading.asObservable()))
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
                guard let self else { return }
                self.isLoading.accept(true)
                self.createProfileUseCase.execute(username: username) { [weak self] result in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.isLoading.accept(false)
                        switch result {
                        case .success:
                            self.onProfileCreated?()
                        case .failure(let error):
                            self.createFailed.accept(error)
                        }
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
}
