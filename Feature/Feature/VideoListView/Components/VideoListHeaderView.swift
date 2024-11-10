//
//  VideoListHeaderView.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import UIKit

final class VideoListHeaderView: UIView {
    // MARK: - UI Components
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "함께 편집할 영상 불러오기"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hex: "787E87")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()
    
    let addVideoButton: IconButton = {
        let button = IconButton()
        let image = UIImage.init(systemName: "photo")
        button.configure(with: image, title: "영상 추가")
        return button
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        
        setupViewHierarchies()
        setupViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with count: Int) {
        subTitleLabel.text = "총 \(count)개를 불러왔어요"
    }
}

// MARK: - Setting
private extension VideoListHeaderView {
    func setupViewHierarchies() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(addVideoButton)
    }
    
    func setupViewConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        addVideoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}
