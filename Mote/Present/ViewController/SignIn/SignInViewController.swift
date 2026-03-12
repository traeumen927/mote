//
//  SignInViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignInViewController: UIViewController {
    
    private var viewModel: SignInViewModel
    
    private let disposeBag = DisposeBag()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(
            barButtonSystemItem: .close,
            target: nil,
            action: nil
        )
    }()
    
    private lazy var doneBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: nil
        )
        button.isEnabled = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What should we call you?"
        label.font = Typography.largeTitle
        label.textColor = SemanticColor.textPrimary.uiColor
        label.textAlignment = .center
        return label
    }()
    
    // MARK: 유저네임 입력 컴포넌트
    private lazy var userNameInputView: LabeledTextFieldView = {
        let configuration = LabeledTextFieldView.Configuration(
            title: "Username",
            placeholder: "a name you like",
            maxLength: 15
        )
        return LabeledTextFieldView(configuration: configuration)
    }()
    
    // MARK: 중복 체크, 정규식 안내 라벨
    private lazy var validationLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.body
        label.textColor = SemanticColor.textSecondary.uiColor
        label.textAlignment = .center
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayout()
        self.bind()
    }
    
    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.userNameInputView)
        self.view.addSubview(self.validationLabel)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.userNameInputView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(72)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.validationLabel.snp.makeConstraints { make in
            make.top.equalTo(self.userNameInputView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func bind() {
        self.userNameInputView.captionTextField.rx.text.orEmpty
            .bind(to: self.viewModel.username)
            .disposed(by: self.disposeBag)
        
        self.doneBarButtonItem.rx.tap
            .bind(to: self.viewModel.createRequested)
            .disposed(by: self.disposeBag)
        
        self.closeBarButtonItem.rx.tap
            .bind(to: self.viewModel.closeRequested)
            .disposed(by: self.disposeBag)
        
        self.userNameInputView.captionTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: self.viewModel.createRequested)
            .disposed(by: self.disposeBag)
        
        self.viewModel.canCreate
            .drive(self.doneBarButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.usernameAvailabilityState
            .observe(on: MainScheduler.instance)
            .bind { [weak self] state in
                self?.renderUsernameAvailability(state: state)
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.isLoading
            .map { !$0 }
            .bind(to: self.userNameInputView.captionTextField.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading in
                guard let self else { return }
                
                if isLoading {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.loadingIndicator)
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
                }
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.createFailed
            .bind { error in
                print("❌ Failed to create profile: \(error.localizedDescription)")
            }
            .disposed(by: self.disposeBag)
    }
    
    @objc
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func renderUsernameAvailability(state: SignInViewModel.UsernameAvailabilityState) {
        switch state {
            
        case .idle:
            self.validationLabel.text = "✨ This will be your unique username"
            
        case .invalidFormat:
            self.validationLabel.text = "❌ 3–15 chars · a–z, 0–9, . and _"
            
        case .checking:
            self.validationLabel.text = "🔎 Looking it up…"
            
        case .available:
            self.validationLabel.text = "✅ That name is all yours"
            
        case .taken:
            self.validationLabel.text = "😅 Looks like that name is taken"
        }
    }
}
