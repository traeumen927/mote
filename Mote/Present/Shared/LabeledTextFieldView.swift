//
//  LabeledTextField.swift
//  Mote
//
//  Created by 홍정연 on 3/10/26.
//

import UIKit
import SnapKit

final class LabeledTextFieldView: UIView {
    
    struct Configuration {
        let title: String
        let placeholder: String
        let maxLength: Int
    }
    
    private let configuration: Configuration
    private var isTextFieldFocused: Bool = false
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.title2
        label.numberOfLines = 1
        return label
    }()
    
    private let captionContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        return view
    }()
    
    let captionTextField: UITextField = {
        let textField = UITextField()
        textField.font = Typography.body
        textField.returnKeyType = .done
        return textField
    }()
    
    private var captionCountLabel: UILabel?
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        setupLayout()
        applyConfiguration()
        applyTheme()
        registerTraitChanges()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCountText(_ text: String) {
        captionCountLabel?.text = text
    }
    
    private func bindActions() {
        captionTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        captionTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        captionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func applyTheme() {
        captionLabel.textColor = SemanticColor.textSecondary.uiColor
        captionContainerView.backgroundColor = SemanticColor.bgApp.uiColor
        
        let borderColor = isTextFieldFocused
        ? SemanticColor.borderFocused.uiColor
        : SemanticColor.borderDefault.uiColor
        
        captionContainerView.layer.borderColor =
            borderColor
                .resolvedColor(with: traitCollection)
                .cgColor
        
        captionContainerView.layer.borderWidth = isTextFieldFocused ? 1.5 : 1.0
        
        captionTextField.textColor = SemanticColor.textPrimary.uiColor
        captionCountLabel?.textColor = SemanticColor.textDisabled.uiColor
    }
    
    private func registerTraitChanges() {
        self.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.applyTheme()
        }
    }
    
    @objc private func textFieldDidBeginEditing() {
        isTextFieldFocused = true
        applyTheme()
    }
    
    @objc private func textFieldDidEndEditing() {
        isTextFieldFocused = false
        applyTheme()
    }
    
    @objc private func textFieldDidChange() {
        guard configuration.maxLength > 0 else { return }

        let text = captionTextField.text ?? ""
        let limitedText = String(text.prefix(configuration.maxLength))

        if text != limitedText {
            captionTextField.text = limitedText
        }

        captionCountLabel?.text = "(\(limitedText.count)/\(configuration.maxLength))"
    }
    
    private func setupLayout() {
        addSubview(captionLabel)
        addSubview(captionContainerView)
        captionContainerView.addSubview(captionTextField)
        
        captionLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        captionContainerView.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(12)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        if configuration.maxLength > 0 {
            let countLabel = UILabel()
            countLabel.font = Typography.caption
            countLabel.textAlignment = .right
            captionContainerView.addSubview(countLabel)
            captionCountLabel = countLabel
            
            captionTextField.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(8)
                $0.verticalEdges.equalToSuperview().inset(8)
                $0.trailing.equalTo(countLabel.snp.leading).offset(-8)
            }
            
            countLabel.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(8)
                $0.centerY.equalTo(captionTextField)
            }
            
            return
        }
        
        captionTextField.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.verticalEdges.equalToSuperview().inset(8)
        }
    }
    
    private func applyConfiguration() {
        captionLabel.text = configuration.title
        captionTextField.placeholder = configuration.placeholder
        
        guard configuration.maxLength > 0 else { return }
        captionCountLabel?.text = "(0/\(configuration.maxLength))"
    }
}
