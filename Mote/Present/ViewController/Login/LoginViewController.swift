//
//  LoginViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    
    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()
    
    private let presenterStore: GoogleSignInPresenterStoreType
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Press. Save. Let it drop."
        label.font = Typography.largeTitle
        label.textColor = SemanticColor.textPrimary.uiColor
        label.textAlignment = .center
        return label
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "GoogleSignInButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    init(viewModel: LoginViewModel, presenterStore: GoogleSignInPresenterStoreType) {
        self.viewModel = viewModel
        self.presenterStore = presenterStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayout()
        self.bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenterStore.presentingViewController = self
    }
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.googleLoginButton)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        self.googleLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(32)
        }
    }
    
    private func bind() {
        self.googleLoginButton.rx.tap
            .bind(to: self.viewModel.signInRequested)
            .disposed(by: self.disposeBag)
    }
}
