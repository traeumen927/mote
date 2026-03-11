//
//  WelcomeViewModel.swift
//  Mote
//
//  Created by 홍정연 on 3/11/26.
//

import Foundation
import RxSwift
import RxCocoa

final class WelcomeViewModel {
    private let disposeBag = DisposeBag()
    
    let welcomeMessage: String
    let confirmRequested = PublishRelay<Void>()
    
    var onConfirm: (() -> Void)?
    
    init(username: String) {
        self.welcomeMessage = "Congratulations on joining, \(username)."
        self.bind()
    }
    
    private func bind() {
        self.confirmRequested
            .bind { [weak self] _ in
                self?.onConfirm?()
            }
            .disposed(by: self.disposeBag)
    }
}
