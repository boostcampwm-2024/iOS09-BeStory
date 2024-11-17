//
//  VideoListCollectionViewCell.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import SnapKit
import UIKit

final class VideoListCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "VideoListCollectionViewCell"
    
    // MARK: - UI Components
    private let thumbnailImageView = UIImageView()
    
    private let durationView = UIView()
    
    private let durationLabel = UILabel()
    
    private let titleLabel = UILabel()
    
    private let authorLabel = UILabel()
    
    private let dateLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    func configure(with presentationModel: VideoListItem) {
        thumbnailImageView.image = UIImage(data: presentationModel.thumbnailImage)
        durationLabel.text = presentationModel.duration
        titleLabel.text = presentationModel.title
        authorLabel.text = presentationModel.authorTitle
        dateLabel.text = presentationModel.date
    }
}

// MARK: - Setting
private extension VideoListCollectionViewCell {
    func setupViewAttributes() {
        setupThumbnailImageView()
        setupTitleLabel()
        setupDurationLabel()
        setupDurationView()
        setupAuthorLabel()
        setupDateLabel()
    }
    
    func setupViewHierarchies() {
        addSubview(thumbnailImageView)
        addSubview(durationView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(dateLabel)
        
        durationView.addSubview(durationLabel)
    }
    
    func setupViewConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(100)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        durationView.snp.makeConstraints { make in
            make.trailing.equalTo(thumbnailImageView.snp.trailing).inset(10)
            make.bottom.equalTo(thumbnailImageView.snp.bottom).inset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        authorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setupThumbnailImageView() {
        thumbnailImageView.layer.cornerRadius = 20
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
    }
    
    func setupTitleLabel() {
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.numberOfLines = 1
    }
    
    func setupDurationLabel() {
        durationLabel.textColor = UIColor(hex: "C9C9C9")
        durationLabel.font = UIFont.boldSystemFont(ofSize: 15)
        durationLabel.numberOfLines = 1
    }
    
    func setupDurationView() {
        durationView.layer.cornerRadius = 7
        durationView.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    func setupAuthorLabel() {
        authorLabel.textColor = UIColor(hex: "7A808A")
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        authorLabel.numberOfLines = 1
    }
    
    func setupDateLabel() {
        dateLabel.textColor = UIColor(hex: "7C818B")
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.numberOfLines = 1
    }
}
