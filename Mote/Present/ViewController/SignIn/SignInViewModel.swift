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
    private let checkUsernameDuplicateUseCase: CheckUsernameDuplicateUseCase
    private let fetchProfileUseCase: FetchProfileUseCase
    private let signOutUseCase: SignOutUseCase
    
    private typealias CreateAvailabilityContext = (
        username: String,
        availability: UsernameAvailabilityState,
        isLoading: Bool
    )
    
    enum UsernameAvailabilityState: Equatable {
        case idle
        case invalidFormat
        case checking
        case available
        case taken
    }
    
    private static let usernamePattern = "^[a-z0-9._]{3,15}$"
    
    var onProfileCreated: ((Profile) -> Void)?
    
    let username = BehaviorRelay<String>(value: "")
    let createRequested = PublishRelay<Void>()
    let closeRequested = PublishRelay<Void>()
    let isLoading = BehaviorRelay<Bool>(value: false)
    let createFailed = PublishRelay<Error>()
    let usernameAvailabilityState = BehaviorRelay<UsernameAvailabilityState>(value: .idle)
    
    lazy var canCreate: Driver<Bool> = Driver
        .combineLatest(
            self.usernameAvailabilityState.asDriver(),
            self.isLoading.asDriver()
        ) { availability, isLoading in
            availability == .available && isLoading == false
        }
    
    init(
        createProfileUseCase: CreateProfileUseCase,
        checkUsernameDuplicateUseCase: CheckUsernameDuplicateUseCase,
        fetchProfileUseCase: FetchProfileUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.createProfileUseCase = createProfileUseCase
        self.checkUsernameDuplicateUseCase = checkUsernameDuplicateUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.signOutUseCase = signOutUseCase
        self.bind()
    }
    
    private func bind() {
        self.bindUsernameValidation()
        
        let createAvailabilityContext = Observable
            .combineLatest(
                self.username.asObservable(),
                self.usernameAvailabilityState.asObservable(),
                self.isLoading.asObservable()
            )
            .map { username, availability, isLoading -> CreateAvailabilityContext in
                (
                    username: username,
                    availability: availability,
                    isLoading: isLoading
                )
            }
        
        self.createRequested
            .withLatestFrom(createAvailabilityContext)
            .filter { context in
                context.availability == .available && context.isLoading == false
            }
            .map { context in
                context.username.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    private func bindUsernameValidation() {
        let normalizedUsername = self.username
            .asObservable()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
        
        normalizedUsername
            .observe(on: MainScheduler.instance)
            .bind { [weak self] username in
                guard let self else { return }
                
                if username.isEmpty {
                    self.usernameAvailabilityState.accept(.idle)
                    return
                }
                
                if Self.isValidUsername(username) {
                    self.usernameAvailabilityState.accept(.checking)
                } else {
                    self.usernameAvailabilityState.accept(.invalidFormat)
                }
            }
            .disposed(by: self.disposeBag)
        
        normalizedUsername
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { Self.isValidUsername($0) }
            .flatMapLatest { [weak self] username -> Observable<UsernameAvailabilityState> in
                guard let self else { return .empty() }
                return self.checkUsernameDuplicate(username: username)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: self.usernameAvailabilityState)
            .disposed(by: self.disposeBag)
    }
    
    private func checkUsernameDuplicate(username: String) -> Observable<UsernameAvailabilityState> {
        Observable.create { [weak self] observer in
            self?.checkUsernameDuplicateUseCase.execute(username: username) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let isDuplicated):
                        observer.onNext(isDuplicated ? .taken : .available)
                    case .failure:
                        observer.onNext(.taken)
                    }
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func isValidUsername(_ username: String) -> Bool {
        username.range(of: Self.usernamePattern, options: .regularExpression) != nil
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
                    
                    let completedProfile = profile.username.isEmpty
                    ? Profile(
                        uid: profile.uid,
                        username: username,
                        createAt: profile.createAt,
                        lastActiveAt: profile.lastActiveAt
                    )
                    : profile
                    
                    ProfileSession.shared.update(profile: completedProfile)
                    self.onProfileCreated?(completedProfile)
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

