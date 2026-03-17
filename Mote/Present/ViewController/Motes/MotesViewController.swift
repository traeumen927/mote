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
    private let driftScene = DriftScene(size: .zero)
    
    // MARK: 우측 상단 리프레시 버튼
    private lazy var refreshBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: nil,
            action: nil
        )
        return button
    }()
    
    // MARK: 우측 상단 편집 버튼
    private lazy var menuBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: nil,
            action: nil
        )
        return button
    }()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.spriteView.isPaused = false
        
        DispatchQueue.main.async { [weak self] in
            self?.applyRandomItems()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.spriteView.isPaused = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sceneSize = self.spriteView.bounds.size
        self.driftScene.updateWorldBounds(for: sceneSize)
    }
    
    private func setupLayout() {
        self.navigationItem.title = "Motes"
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        self.navigationItem.rightBarButtonItems = [menuBarButtonItem, refreshBarButtonItem]
        
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
    
    private func applyRandomItems() {
        let randomEmotions = self.viewModel.makeRandomEmotionRecords(limit: 30)
        self.driftScene.apply(emotions: randomEmotions)
    }
}
