//
//  LoginViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

final class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase
    
    let signInRequested = PublishRelay<Void>()
    
    init(signInWithGoogleUseCase: SignInWithGoogleUseCase) {
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        self.bind()
    }
    
    private func bind() {
        self.signInRequested
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self else { return }
                self.signInWithGoogleUseCase.execute { result in
                    switch result {
                    case .success(let user):
                        print("✅ Google sign in success: \(user.uid)")
                    case .failure(let error):
                        print("❌ Google sign in failed: \(error.localizedDescription)")
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
}
