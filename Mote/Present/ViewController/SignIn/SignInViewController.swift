//
//  SignInViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import UIKit
import SnapKit

final class SignInViewController: UIViewController {
    
    private var viewModel: SignInViewModel
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayout()
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
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.userNameInputView)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        self.userNameInputView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(90)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
