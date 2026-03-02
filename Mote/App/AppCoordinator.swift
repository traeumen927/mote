//
//  AppCoordinator.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import FirebaseAuth

final class AppCoordinator {
    
    // MARK: Root -> Auth 있으면 main, 없으면 login 진입
    private enum RootFlow {
        case auth
        case login
        case main
    }
    
    private weak var window: UIWindow?
    private let googleSignInPresenterStore: GoogleSignInPresenterStoreType
    private let googleAuthService: GoogleAuthServicing
    private let authRepository: AuthRepository
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var currentRootFlow: RootFlow?
    
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
        self.showAuthViewControllerIfNeeded()
        self.startAuthStateListening()
    }
    
    // MARK: Auth 응답 전 잠시 보여지는 뷰
    private func showAuthViewControllerIfNeeded() {
        guard self.currentRootFlow == nil else { return }
        
        self.window?.rootViewController = self.makeAuthViewController()
        self.window?.makeKeyAndVisible()
        self.currentRootFlow = .auth
    }
    
    // MARK: Auth Listener 실행
    private func startAuthStateListening() {
        self.authStateListenerHandle = self.authRepository.addAuthStateListener { [weak self] user in
            self?.setRootViewController(isAuthenticated: user != nil)
        }
    }
    
    // MARK: Auth Listener 제거
    private func stopAuthStateListening() {
        guard let authStateListenerHandle else { return }
        self.authRepository.removeAuthStateListener(authStateListenerHandle)
        self.authStateListenerHandle = nil
    }
    
    // MARK: Root View Controller 결정
    private func setRootViewController(isAuthenticated: Bool) {
        let nextRootFlow: RootFlow = isAuthenticated ? .main : .login
        guard self.currentRootFlow != nextRootFlow else { return }
        
        let nextRootViewController: UIViewController = isAuthenticated
        ? self.makeMainViewController()
        : self.makeLoginViewController()
        
        self.window?.rootViewController = nextRootViewController
        self.window?.makeKeyAndVisible()
        self.currentRootFlow = nextRootFlow
    }
    
    private func makeLoginViewController() -> UIViewController {
        let signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository: self.authRepository)
        let viewModel = LoginViewModel(signInWithGoogleUseCase: signInWithGoogleUseCase)
        return LoginViewController(viewModel: viewModel, presenterStore: self.googleSignInPresenterStore)
    }
    
    private func makeAuthViewController() -> UIViewController {
        AuthViewController()
    }
    
    private func makeMainViewController() -> UIViewController {
        let signOutUseCase = SignOutUseCase(authRepository: self.authRepository)
        let viewModel = MainTabViewModel(signOutUseCase: signOutUseCase)
        return MainTabViewController(viewModel: viewModel)
    }
}
