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
    
    private let emotionLabel = UILabel()
    private let captionLabel = UILabel()
    private let createdAtLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        emotion: String,
        caption: String,
        createdAtText: String
    ) {
        self.emotionLabel.text = emotion
        self.captionLabel.text = caption.isEmpty ? "-" : caption
        self.createdAtLabel.text = createdAtText
    }
    
    private func setupLayout() {
        self.backgroundColor = SemanticColor.bgGrouped.uiColor
        self.selectionStyle = .none
        
        self.emotionLabel.font = Typography.largeTitle
        self.emotionLabel.textColor = SemanticColor.textPrimary.uiColor
        
        self.captionLabel.font = Typography.body
        self.captionLabel.textColor = SemanticColor.textSecondary.uiColor
        self.captionLabel.numberOfLines = 0
        
        self.createdAtLabel.font = Typography.bodySmall
        self.createdAtLabel.textColor = SemanticColor.textSecondary.uiColor
        self.createdAtLabel.textAlignment = .right
        
        let topStack = UIStackView(arrangedSubviews: [self.emotionLabel, self.createdAtLabel])
        topStack.axis = .horizontal
        topStack.alignment = .top
        topStack.distribution = .fill
        topStack.spacing = 8
        
        let stack = UIStackView(arrangedSubviews: [topStack, self.captionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
        self.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
