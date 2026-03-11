//
//  AppCoordinator.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class AppCoordinator {
    
    // MARK: Root -> Auth 있으면 main, 없으면 login 진입
    private enum AppSessionState {
        case resolving
        case unauthenticated
        case profileMissing
        case authenticated
    }
    
    private weak var window: UIWindow?
    private let googleSignInPresenterStore: GoogleSignInPresenterStoreType
    private let googleAuthService: GoogleAuthServicing
    private let authRepository: AuthRepository
    private let fetchProfileUseCase: FetchProfileUseCase
    private let createProfileUseCase: CreateProfileUseCase
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var currentRootFlow: AppSessionState?
    
    init(
        window: UIWindow,
        googleSignInPresenterStore: GoogleSignInPresenterStoreType = GoogleSignInPresenterStore(),
        googleAuthService: GoogleAuthServicing? = nil
    ) {
        self.window = window
        self.googleSignInPresenterStore = googleSignInPresenterStore
        let googleAuthService = googleAuthService ?? GoogleAuthService(presenterStore: googleSignInPresenterStore)
        self.googleAuthService = googleAuthService
        self.authRepository = AuthRepositoryImpl(googleAuthService: googleAuthService)
        
        let profileRepository = ProfileRepositoryImpl(firestore: Firestore.firestore())
        self.fetchProfileUseCase = FetchProfileUseCase(profileRepository: profileRepository)
        self.createProfileUseCase = CreateProfileUseCase(profileRepository: profileRepository)
    }
    
    deinit {
        self.stopAuthStateListening()
    }
    
    func start() {
        self.setRootViewController(for: .resolving)
        self.startAuthStateListening()
    }
    
    // MARK: Auth Listener 실행
    private func startAuthStateListening() {
        self.authStateListenerHandle = self.authRepository.addAuthStateListener { [weak self] user in
            self?.resolveAppSessionState(user: user) { state in
                self?.setRootViewController(for: state)
            }
        }
    }
    
    // MARK: Auth Listener 제거
    private func stopAuthStateListening() {
        guard let authStateListenerHandle else { return }
        self.authRepository.removeAuthStateListener(authStateListenerHandle)
        self.authStateListenerHandle = nil
    }
    
    // MARK: Root View Controller 결정
    private func setRootViewController(for state: AppSessionState) {
        guard self.currentRootFlow != state else { return }
        
        let nextRootViewController: UIViewController
        switch state {
        case .resolving:
            nextRootViewController = self.makeAuthViewController()
        case .unauthenticated:
            nextRootViewController = self.makeLoginViewController()
        case .profileMissing:
            nextRootViewController = self.makeSignInViewController()
        case .authenticated:
            nextRootViewController = self.makeMainViewController()
        }
        
        self.window?.rootViewController = nextRootViewController
        self.window?.makeKeyAndVisible()
        self.currentRootFlow = state
    }
    
    private func resolveAppSessionState(user: User?, completion: @escaping (AppSessionState) -> Void) {
        guard user != nil else {
            ProfileSession.shared.clear()
            completion(.unauthenticated)
            return
        }
        
        self.fetchProfileUseCase.execute { result in
            switch result {
            case .success(let profile):
                guard let profile else {
                    ProfileSession.shared.clear()
                    completion(.profileMissing)
                    return
                }
                
                ProfileSession.shared.update(profile: profile)
                completion(.authenticated)
            case .failure:
                ProfileSession.shared.clear()
                completion(.unauthenticated)
            }
        }
    }
    
    private func makeLoginViewController() -> UIViewController {
        let signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository: self.authRepository)
        let viewModel = LoginViewModel(signInWithGoogleUseCase: signInWithGoogleUseCase)
        let viewControlelr = LoginViewController(viewModel: viewModel, presenterStore: self.googleSignInPresenterStore)
        return UINavigationController(rootViewController: viewControlelr)
    }
    
    private func makeSignInViewController() -> UIViewController {
        let signOutUseCase = SignOutUseCase(authRepository: self.authRepository)
        let viewModel = SignInViewModel(
            createProfileUseCase: self.createProfileUseCase,
            fetchProfileUseCase: self.fetchProfileUseCase,
            signOutUseCase: signOutUseCase
        )
        let signInViewController = SignInViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: signInViewController)
        
        viewModel.onProfileCreated = { [weak self, weak navigationController] username in
            let welcomeViewModel = WelcomeViewModel(username: username)
            welcomeViewModel.onConfirm = { [weak self] in
                self?.setRootViewController(for: .authenticated)
            }
            let welcomeViewController = WelcomeViewController(viewModel: welcomeViewModel)
            navigationController?.pushViewController(welcomeViewController, animated: true)
        }
        return UINavigationController(rootViewController: SignInViewController(viewModel: viewModel))
    }
    
    private func makeAuthViewController() -> UIViewController {
        AuthViewController()
    }
    
    private func makeMainViewController() -> UIViewController {
        let signOutUseCase = SignOutUseCase(authRepository: self.authRepository)
        let viewModel = MainTabViewModel(
            signOutUseCase: signOutUseCase,
            firestore: Firestore.firestore(),
            uidProvider: ProfileSession.shared
        )
        return MainTabViewController(viewModel: viewModel)
    }
}
