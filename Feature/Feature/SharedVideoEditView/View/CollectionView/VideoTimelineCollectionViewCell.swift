//
//  VideoTimelineCollectionViewCell.swift
//  Feature
//
//  Created by 이숲 on 11/28/24.
//

import SnapKit
import UIKit

final class VideoTimelineCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    static let reuseIdentifier: String = "VideoTimelineCollectionViewCell"

    // MARK: - UI Component

    private let thumbnailImageView = UIImageView()
    private let durationView = UIView()
    private let durationLabel = UILabel()

    // MARK: - Initializer

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

    // MARK: - Configuration

    func configure(with presentationModel: VideoTimelineItem) {
        thumbnailImageView.image = UIImage(data: presentationModel.thumbnailImage)
        durationLabel.text = presentationModel.duration
    }
}

// MARK: - UI Configure

private extension VideoTimelineCollectionViewCell {
    enum ThumbnailImageViewConstants {
        static let cornerRadius: CGFloat = 10
    }

    enum DurationViewConstants {
        static let cornerRadius: CGFloat = 7
        static let alpha: CGFloat = 0.5
        static let trailingInset: CGFloat = 10
        static let bottomInset: CGFloat = 10
    }

    enum DurationLabelConstants {
        static let textColor = UIColor(hex: "C9C9C9")
        static let font = UIFont.boldSystemFont(ofSize: 15)
        static let numberOfLines: Int = 1
        static let edgesInset: CGFloat = 5
    }

    func setupViewAttributes() {
        setupThumbnailImageView()
        setupDurationView()
        setupDurationLabel()
    }

    func setupThumbnailImageView() {
        thumbnailImageView.layer.cornerRadius = ThumbnailImageViewConstants.cornerRadius
        thumbnailImageView.backgroundColor = .systemGray6
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
    }

    func setupDurationView() {
        durationView.layer.cornerRadius = DurationViewConstants.cornerRadius
        durationView.backgroundColor = .black.withAlphaComponent(DurationViewConstants.alpha)
    }

    func setupDurationLabel() {
        durationLabel.textColor = DurationLabelConstants.textColor
        durationLabel.font = DurationLabelConstants.font
        durationLabel.numberOfLines = DurationLabelConstants.numberOfLines
    }

    func setupViewHierarchies() {
        [
            thumbnailImageView,
            durationView
        ].forEach({
            addSubview($0)
        })

        durationView.addSubview(durationLabel)
    }

    func setupViewConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        durationView.snp.makeConstraints { make in
            make.trailing.equalTo(thumbnailImageView.snp.trailing).inset(DurationViewConstants.trailingInset)
            make.bottom.equalTo(thumbnailImageView.snp.bottom).inset(DurationViewConstants.bottomInset)
        }

        durationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(DurationLabelConstants.edgesInset)
        }
    }
}
