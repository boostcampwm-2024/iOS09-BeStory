//
//  VideoListCollectionViewCell.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import UIKit

final class VideoListCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "VideoListCollectionViewCell"
    
    // MARK: - UI Components
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let durationView = DurationView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "7A808A")
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "7C818B")
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViewHierarchies()
        setupViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    func configure(with presentationModel: VideoListPresentationModel) {
        thumbnailImageView.image = UIImage(data: presentationModel.thumbnailImage)
        durationView.configure(with: presentationModel.duration)
        titleLabel.text = presentationModel.title
        authorLabel.text = presentationModel.authorTitle
        dateLabel.text = presentationModel.date
    }
}

// MARK: - Setting
private extension VideoListCollectionViewCell {
    func setupViewHierarchies() {
        addSubview(thumbnailImageView)
        addSubview(durationView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(dateLabel)
    }
    
    func setupViewConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
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
}
