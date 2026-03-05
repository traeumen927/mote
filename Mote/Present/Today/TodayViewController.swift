//
//  TodayViewController.swift
//  Mote
//
//  Created by 홍정연 on 3/2/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TodayViewController: UIViewController {
    
    private let viewModel: TodayViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: 동적으로 변동되는 CollectionView 높이
    private var emotionContainerHeightConstraint: Constraint?
    
    // MARK: 우측 상단 저장 버튼
    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .done,
            target: nil,
            action: nil
        )
        button.isEnabled = false
        return button
    }()
    
    // MARK: 컬렉션 뷰 프롬프트 라벨
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.text = "How did today feel?"
        label.font = Typography.title2
        label.textColor = SemanticColor.textSecondary.uiColor
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: 이모션 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        let layout = HashFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = .zero
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.allowsMultipleSelection = false
        view.register(TodayEmotionCell.self, forCellWithReuseIdentifier: TodayEmotionCell.cellId)
        view.dataSource = self
        return view
    }()
    
    // MARK: 캡션 프롬프트 라벨
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "Caption"
        label.font = Typography.title2
        label.textColor = SemanticColor.textSecondary.uiColor
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: 캡션 컨테이너 뷰
    private let captionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = SemanticColor.bgApp.uiColor
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.0
        view.layer.borderColor = SemanticColor.borderDefault.uiColor.cgColor
        return view
    }()
    
    // MARK: 캡션 타이틀 뷰
    private let captionTextField: UITextField = {
        let textField = UITextField()
        textField.font = Typography.body
        textField.textColor = SemanticColor.textPrimary.uiColor
        textField.placeholder = "A few words about today…"
        textField.returnKeyType = .done
        return textField
    }()
    
    // MARK: 캡션 글자수 라벨
    private let captionCountLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.caption
        label.textColor = SemanticColor.textDisabled.uiColor
        label.textAlignment = .right
        label.text = "(0/\(TodayViewModel.captionMaxLength))"
        return label
    }()
    
    init(viewModel: TodayViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.refreshForTabReturnIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateEmotionContainerHeightIfNeeded()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = SemanticColor.bgApp.uiColor
        
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
        
        self.view.addSubview(self.emotionLabel)
        self.view.addSubview(self.collectionView)
        
        self.view.addSubview(self.captionLabel)
        self.view.addSubview(self.captionContainerView)
        self.captionContainerView.addSubview(self.captionTextField)
        self.captionContainerView.addSubview(self.captionCountLabel)
        self.captionContainerView.isHidden = true
        
        self.emotionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.emotionLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(12)
            self.emotionContainerHeightConstraint = make.height.equalTo(0).constraint
        }
        
        self.captionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.captionContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.captionLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        self.captionTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.verticalEdges.equalToSuperview().inset(8)
            make.trailing.equalTo(self.captionCountLabel.snp.leading).offset(-8)
        }
        
        self.captionCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(self.captionTextField)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func bind() {
        self.collectionView.reloadData()
        
        self.viewModel.observeTodayEmotion()
        
        self.viewModel.titleText
            .drive(self.navigationItem.rx.title)
            .disposed(by: self.disposeBag)
        
        // MARK: Right BarButton으로 저장
        self.saveBarButtonItem.rx.tap
            .bind { [weak self] in
                self?.viewModel.saveTodayEmotion()
            }
            .disposed(by: self.disposeBag)
        
        // MARK: ReturnKey로 저장
        self.captionTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] in
                self?.viewModel.saveTodayEmotion()
            }
            .disposed(by: disposeBag)
        
        // MARK: 감정이 선택됨
        self.collectionView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let self else { return }
                self.captionContainerView.isHidden = false
                self.viewModel.selectEmotion(at: indexPath.item)
            }
            .disposed(by: self.disposeBag)
        
        self.captionTextField.rx.text
            .bind { [weak self] text in
                guard let self else { return }
                let sanitizedCaption = self.viewModel.updateCaption(text)
                if self.captionTextField.text != sanitizedCaption {
                    self.captionTextField.text = sanitizedCaption
                }
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.initialStateLoaded
            .bind { [weak self] state in
                guard let self else { return }
                let indexPath = IndexPath(item: state.selectedIndex, section: 0)
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                self.captionTextField.text = state.caption
                self.captionContainerView.isHidden = false
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.resetForNewDay
            .bind { [weak self] in
                guard let self else { return }
                self.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                    self.collectionView.deselectItem(at: indexPath, animated: false)
                }
                self.captionTextField.text = nil
                self.captionContainerView.isHidden = true
                self.captionTextField.resignFirstResponder()
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.canSave
            .drive(self.saveBarButtonItem.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.captionCountText
            .drive(self.captionCountLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.viewModel.isLoading
            .map { !$0 }
            .bind(to: self.collectionView.rx.isUserInteractionEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.saveSucceeded
            .bind { [weak self] data in
                self?.captionTextField.resignFirstResponder()
                print("✅ Saved emotion: \(data.emotion), dateKey: \(data.dateKey)")
            }
            .disposed(by: self.disposeBag)
        
        self.viewModel.saveFailed
            .bind { error in
                print("❌ Failed to save emotion: \(error.localizedDescription)")
            }
            .disposed(by: self.disposeBag)
    }
    
    private func updateEmotionContainerHeightIfNeeded() {
        self.collectionView.layoutIfNeeded()
        let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        let targetHeight = ceil(contentHeight + 8)
        guard targetHeight > 0 else { return }
        
        let currentHeight = self.emotionContainerHeightConstraint?.layoutConstraints.first?.constant ?? 0
        guard abs(currentHeight - targetHeight) > 0.5 else { return }
        
        self.emotionContainerHeightConstraint?.update(offset: targetHeight)
    }
    
    @objc
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayEmotionCell.cellId, for: indexPath) as? TodayEmotionCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: self.viewModel.items[indexPath.item].displayText)
        return cell
    }
}

