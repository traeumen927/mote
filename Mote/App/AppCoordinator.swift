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
            let state = self?.resolveAppSessionState(user: user) ?? .resolving
            self?.setRootViewController(for: state)
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
    
    private func resolveAppSessionState(user: User?) -> AppSessionState {
        guard let user else { return .unauthenticated }
        
        let displayName = user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasProfile = !(displayName?.isEmpty ?? true)
        return hasProfile ? .authenticated : .profileMissing
    }
    
    private func makeLoginViewController() -> UIViewController {
        let signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository: self.authRepository)
        let viewModel = LoginViewModel(signInWithGoogleUseCase: signInWithGoogleUseCase)
        return LoginViewController(viewModel: viewModel, presenterStore: self.googleSignInPresenterStore)
    }
    
    private func makeSignInViewController() -> UIViewController {
        let viewModel = SignInViewModel()
        return SignInViewController(viewModel: viewModel)
    }
    
    private func makeAuthViewController() -> UIViewController {
        AuthViewController()
    }
    
    private func makeMainViewController() -> UIViewController {
        let signOutUseCase = SignOutUseCase(authRepository: self.authRepository)
        let viewModel = MainTabViewModel(
            signOutUseCase: signOutUseCase,
            firestore: Firestore.firestore()
        )
        return MainTabViewController(viewModel: viewModel)
    }
}
