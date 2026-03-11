//
//  WelcomeViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/11/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WelcomeViewController: UIViewController {
    private let viewModel: WelcomeViewModel
    private let disposeBag = DisposeBag()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.title2
        label.textColor = SemanticColor.textPrimary.uiColor
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Okay"
        button.configuration?.cornerStyle = .large
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
        self.title = "Welcome"
        self.navigationItem.hidesBackButton = true
        
        self.view.addSubview(self.welcomeLabel)
        self.view.addSubview(self.confirmButton)
        
        self.welcomeLabel.text = self.viewModel.welcomeMessage
        
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
        self.confirmButton.rx.tap
            .bind(to: self.viewModel.confirmRequested)
            .disposed(by: self.disposeBag)
    }
}
