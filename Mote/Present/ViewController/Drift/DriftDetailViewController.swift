//
//  DriftDetailViewController.swift
//  Mote
//
//  Created by 홍정연 on 4/23/26.
//

import UIKit
import SnapKit

final class DriftDetailViewController: UIViewController {
    private let viewModel: DriftDetailViewModel
    private let onVisibilityChanged: (Bool) -> Void

    private let emotionLabel = UILabel()
    private let dateLabel = UILabel()
    private let captionTitleLabel = UILabel()
    private let captionLabel = UILabel()
    private let hiddenTitleLabel = UILabel()
    private let hiddenSwitch = UISwitch()

    init(
        viewModel: DriftDetailViewModel,
        onVisibilityChanged: @escaping (Bool) -> Void
    ) {
        self.viewModel = viewModel
        self.onVisibilityChanged = onVisibilityChanged
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.configureContent()
    }

    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor

        self.emotionLabel.font = .systemFont(ofSize: 52)
        self.emotionLabel.textAlignment = .center

        self.dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        self.dateLabel.textColor = .secondaryLabel

        self.captionTitleLabel.text = "Caption"
        self.captionTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        self.captionTitleLabel.textColor = .secondaryLabel

        self.captionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        self.captionLabel.numberOfLines = 0

        self.hiddenTitleLabel.text = "Hide"
        self.hiddenTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        self.hiddenSwitch.addTarget(self, action: #selector(self.didToggleHiddenSwitch(_:)), for: .valueChanged)

        let visibilityStack = UIStackView(arrangedSubviews: [self.hiddenTitleLabel, UIView(), self.hiddenSwitch])
        visibilityStack.axis = .horizontal
        visibilityStack.alignment = .center
        visibilityStack.spacing = 12

        let stack = UIStackView(arrangedSubviews: [
            self.emotionLabel,
            self.dateLabel,
            self.captionTitleLabel,
            self.captionLabel,
            visibilityStack
        ])
        stack.axis = .vertical
        stack.spacing = 12

        self.view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(24)
        }
    }

    private func configureContent() {
        self.emotionLabel.text = self.viewModel.emotion
        self.dateLabel.text = self.viewModel.dateText
        self.captionLabel.text = self.viewModel.captionText
        self.hiddenSwitch.isOn = self.viewModel.isHidden
    }

    @objc
    private func didToggleHiddenSwitch(_ sender: UISwitch) {
        self.onVisibilityChanged(sender.isOn)
    }
}
