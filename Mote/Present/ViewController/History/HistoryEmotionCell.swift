//
//  HistoryEmotionCell.swift
//  Mote
//
//  Created by 홍정연 on 4/28/26.
//

import UIKit
import SnapKit

final class HistoryEmotionCell: UITableViewCell {
    static let reuseIdentifier = "HistoryEmotionCell"
    
    var onHiddenSwitchChanged: ((Bool) -> Void)?
    
    private let emotionLabel = UILabel()
    private let captionLabel = UILabel()
    private let createdAtLabel = UILabel()
    private let hiddenTitleLabel = UILabel()
    private let hiddenSwitch = UISwitch()
    
    private var isProgrammaticSwitchChange = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.onHiddenSwitchChanged = nil
    }
    
    func configure(
        emotion: String,
        caption: String,
        isHidden: Bool,
        createdAtText: String
    ) {
        self.emotionLabel.text = emotion
        self.captionLabel.text = caption.isEmpty ? "-" : caption
        self.createdAtLabel.text = createdAtText
        self.isProgrammaticSwitchChange = true
        self.hiddenSwitch.isOn = isHidden
        self.isProgrammaticSwitchChange = false
    }
    
    private func setupLayout() {
        self.backgroundColor = SemanticColor.bgGrouped.uiColor
        self.selectionStyle = .none
        
        self.emotionLabel.font = Typography.bodyLarge
        self.emotionLabel.textColor = SemanticColor.textPrimary.uiColor
        
        self.captionLabel.font = Typography.body
        self.captionLabel.textColor = SemanticColor.textSecondary.uiColor
        self.captionLabel.numberOfLines = 2
        
        self.createdAtLabel.font = Typography.body
        self.createdAtLabel.textColor = SemanticColor.textSecondary.uiColor
        
        self.hiddenTitleLabel.text = "Hidden"
        self.hiddenTitleLabel.font = Typography.body
        self.hiddenTitleLabel.textColor = SemanticColor.textPrimary.uiColor
        
        self.hiddenSwitch.addTarget(self, action: #selector(self.didChangeSwitchValue), for: .valueChanged)
        
        let hiddenStack = UIStackView(arrangedSubviews: [self.hiddenTitleLabel, self.hiddenSwitch])
        hiddenStack.axis = .horizontal
        hiddenStack.alignment = .center
        hiddenStack.distribution = .equalSpacing
        
        let stack = UIStackView(arrangedSubviews: [self.emotionLabel, self.captionLabel, self.createdAtLabel, hiddenStack])
        stack.axis = .vertical
        stack.spacing = 8
        
        self.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    @objc
    private func didChangeSwitchValue() {
        guard self.isProgrammaticSwitchChange == false else { return }
        self.onHiddenSwitchChanged?(self.hiddenSwitch.isOn)
    }
}
