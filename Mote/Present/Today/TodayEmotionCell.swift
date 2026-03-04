//
//  TodayEmotionCell.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit

final class TodayEmotionCell: UICollectionViewCell {
    static let cellId = "TodayEmotionCell"
    
    override var isSelected: Bool {
        didSet {
            self.updateUI()
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = SemanticColor.textPrimary.uiColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
        self.updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        self.label.text = text
    }
    
    private func setupLayout() {
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.borderColor = SemanticColor.borderStrong.uiColor.cgColor
        self.contentView.addSubview(self.label)
        
        self.label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
    }
    
    private func updateUI() {
        self.contentView.layer.borderWidth = self.isSelected ? 1 : 0
        self.contentView.backgroundColor = self.isSelected
            ? SemanticColor.bgElevated.uiColor
            : SemanticColor.bgSurface.uiColor
    }
}
