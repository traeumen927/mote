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
    static let rowHeight: CGFloat = 76
    
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
        self.emotionLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.emotionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.captionLabel.font = Typography.body
        self.captionLabel.textColor = SemanticColor.textSecondary.uiColor
        self.captionLabel.numberOfLines = 2
        self.captionLabel.lineBreakMode = .byTruncatingTail
        self.captionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.captionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.createdAtLabel.font = Typography.bodySmall
        self.createdAtLabel.textColor = SemanticColor.textSecondary.uiColor
        self.createdAtLabel.textAlignment = .right
        self.createdAtLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.createdAtLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.contentView.addSubview(self.emotionLabel)
        self.contentView.addSubview(self.captionLabel)
        self.contentView.addSubview(self.createdAtLabel)
        
        self.emotionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        self.createdAtLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        self.captionLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.emotionLabel.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(self.createdAtLabel.snp.leading).offset(-12)
            make.top.bottom.equalToSuperview().inset(12)
        }
    }
}
