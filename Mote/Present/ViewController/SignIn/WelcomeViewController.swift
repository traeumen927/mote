//
//  WelcomeViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/11/26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Lottie

final class WelcomeViewController: UIViewController {
    private let viewModel: WelcomeViewModel
    private let disposeBag = DisposeBag()
    
    private let successAnimateView: LottieAnimationView = {
        let view = LottieAnimationView(name: "confetti")
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.animationSpeed = 1.0
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.largeTitle
        label.textColor = SemanticColor.textPrimary.uiColor
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.72
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.bodyLarge
        label.textColor = SemanticColor.textSecondary.uiColor
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Your account is ready to begin."
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [welcomeLabel, contentLabel])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.backgroundColor = .clear
        return stack
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = SemanticColor.buttonPrimaryBackground.uiColor
        
        var attributes = AttributeContainer()
        attributes.font = Typography.body
        
        config.attributedTitle = AttributedString("Get started", attributes: attributes)
        button.configuration = config
        return button
    }()
    
    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
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
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        self.navigationItem.hidesBackButton = true
        
        self.welcomeLabel.text = self.viewModel.welcomeMessage
        
        self.view.addSubview(self.successAnimateView)
        self.view.addSubview(self.textStackView)
        self.view.addSubview(self.confirmButton)
        
        self.successAnimateView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        self.textStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        self.confirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(52)
        }
        
        successAnimateView.play()
    }
    
    private func bind() {
        self.confirmButton.rx.tap
            .bind(to: self.viewModel.confirmRequested)
            .disposed(by: self.disposeBag)
    }
}
