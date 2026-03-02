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
        case login
        case main
    }

    private weak var window: UIWindow?
    private let googleAuthService: GoogleAuthServicing
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var currentRootFlow: RootFlow?

    init(window: UIWindow, googleAuthService: GoogleAuthServicing = GoogleAuthService()) {
        self.window = window
        self.googleAuthService = googleAuthService
    }

    deinit {
        self.stopAuthStateListening()
    }

    func start() {
        self.startAuthStateListening()
    }

    // MARK: Auth Listener 실행
    private func startAuthStateListening() {
        self.authStateListenerHandle = self.googleAuthService.addAuthStateListener { [weak self] user in
            self?.setRootViewController(isAuthenticated: user != nil)
        }
    }

    // MARK: Auth Listener 제거
    private func stopAuthStateListening() {
        guard let authStateListenerHandle else { return }
        self.googleAuthService.removeAuthStateListener(authStateListenerHandle)
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
        let signInWithGoogleUseCase = SignInWithGoogleUseCase(googleAuthService: self.googleAuthService)
        let viewModel = LoginViewModel(signInWithGoogleUseCase: signInWithGoogleUseCase)
        return LoginViewController(viewModel: viewModel)
    }

    private func makeMainViewController() -> UIViewController {
        MainTabViewController()
    }
}
