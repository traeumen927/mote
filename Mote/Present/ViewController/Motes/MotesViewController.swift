//
//  MotesViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/16/26.
//

import UIKit
import SpriteKit
import SnapKit

final class MotesViewController: UIViewController {
    let viewModel: MotesViewModel
    
    private let spriteView = SKView()
    private let motesScene = MotesScene(size: .zero)
    
    init(viewModel: MotesViewModel) {
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
        self.applyRandomItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.spriteView.isPaused = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.spriteView.isPaused = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.motesScene.updateWorldBounds(for: self.spriteView.bounds.size)
    }
    
    private func setupLayout() {
        self.navigationItem.title = "Motes"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.spriteView.backgroundColor = .clear
        self.spriteView.ignoresSiblingOrder = true
        
        self.view.addSubview(self.spriteView)
        self.spriteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupScene() {
        self.motesScene.scaleMode = .resizeFill
        self.spriteView.presentScene(self.motesScene)
    }
    
    private func applyRandomItems() {
        let randomItems = (0..<30).map { _ in
            EmotionItem.allCases.randomElement()?.rawValue ?? EmotionItem.happy.rawValue
        }
        self.motesScene.applyRandomItems(randomItems)
    }
}
