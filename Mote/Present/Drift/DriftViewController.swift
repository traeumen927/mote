//
//  DriftViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SpriteKit
import SnapKit

final class DriftViewController: UIViewController {
    
    private let viewModel: DriftViewModel
    
    private let spriteView = SKView()
    private let driftScene = DriftScene(size: .zero)
    
    init(viewModel: DriftViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.setupScene()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchRecentEmotions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let sceneSize = self.spriteView.bounds.size
        self.driftScene.updateWorldBounds(for: sceneSize)
    }
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.spriteView.backgroundColor = .clear
                self.spriteView.ignoresSiblingOrder = true

                self.view.addSubview(self.spriteView)
                self.spriteView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
    }
    
    private func setupScene() {
        self.driftScene.scaleMode = .resizeFill
        self.spriteView.presentScene(self.driftScene)
    }
    
    private func bind() {
        
    }
}
