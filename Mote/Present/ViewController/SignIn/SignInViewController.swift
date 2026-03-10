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
    
    // MARK: 유저네임 입력 컴포넌트
    private lazy var userNameInputView: LabeledTextFieldView = {
        let configuration = LabeledTextFieldView.Configuration(
            title: "Username",
            placeholder: "a name you like",
            maxLength: 15
        )
        return LabeledTextFieldView(configuration: configuration)
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.title2
        label.textColor = SemanticColor.textPrimary.uiColor
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Okay"
        button.configuration?.cornerStyle = .large
        button.isHidden = true
        return button
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
        self.title = "What should we call you?"
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
        
        self.view.addSubview(self.userNameInputView)
        self.view.addSubview(self.welcomeLabel)
        self.view.addSubview(self.confirmButton)
        
        self.userNameInputView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(72)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(60)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.confirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(52)
        }
    }
    
    private func bind() {
        self.userNameInputView.captionTextField.rx.text.orEmpty
            .bind(to: self.viewModel.username)
            .disposed(by: self.disposeBag)
        
        self.doneBarButtonItem.rx.tap
            .bind(to: self.viewModel.createRequested)
            .disposed(by: self.disposeBag)
        
        self.userNameInputView.captionTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: self.viewModel.createRequested)
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.tap
            .bind(to: self.viewModel.confirmRequested)
            .disposed(by: self.disposeBag)
        
        self.viewModel.canCreate
            .drive(self.doneBarButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.isLoading
            .map { !$0 }
            .bind(to: self.userNameInputView.captionTextField.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(
            self.viewModel.isLoading.asObservable(),
            self.viewModel.isCompleted.asObservable()
        )
        .observe(on: MainScheduler.instance)
        .bind { [weak self] isLoading, isCompleted in
            guard let self else { return }
            
            if isLoading {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.loadingIndicator)
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
                self.navigationItem.rightBarButtonItem = isCompleted ? nil : self.doneBarButtonItem
            }
            
            self.title = isCompleted ? "Welcome" : "What should we call you?"
            self.userNameInputView.isHidden = isCompleted
            self.welcomeLabel.isHidden = !isCompleted
            self.confirmButton.isHidden = !isCompleted
        }
        .disposed(by: self.disposeBag)
        
        self.viewModel.completedUsername
            .observe(on: MainScheduler.instance)
            .bind { [weak self] username in
                self?.welcomeLabel.text = "Congratulations on joining, \(username)."
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.createFailed
            .bind { error in
                print("❌ Failed to create profile: \(error.localizedDescription)")
            }
            .disposed(by: self.disposeBag)
    }
}
