//
//  CustomCircleView.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import SnapKit
import UIKit

enum CircleViewStyle {
    case large
    case small
}

final class CircleView: UIView {
    // MARK: - UI Components

    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let style: CircleViewStyle

    // MARK: - Initiailizer

    init(style: CircleViewStyle) {
        self.style = style
        super.init(frame: .zero)

        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration Method

    func setupConfigure(emoji: String, name: String) {
        emojiLabel.text = emoji
        nameLabel.text = name
    }
}

// MARK: - UI Configure

private extension CircleView {
    enum Constants {
        static let largeEmojiFontSize: CGFloat = 70
        static let largeNameFontSize: CGFloat = 20

        static let offset: CGFloat = 5

        static let smallEmojiFontSize: CGFloat = 40
        static let smallNameFontSize: CGFloat = 15
    }

    func setupViewAttributes() {
        setupEmojiLabel()
        setupNameLabel()
    }

    func setupEmojiLabel() {
        emojiLabel.backgroundColor = .clear
        emojiLabel.textAlignment = .center
        emojiLabel.textColor = .white
        emojiLabel.layer.masksToBounds = true

        switch style {
        case .large:
            emojiLabel.font = .systemFont(ofSize: Constants.largeEmojiFontSize)
        case .small:
            emojiLabel.font = .systemFont(ofSize: Constants.smallEmojiFontSize)
        }
    }

    func setupNameLabel() {
        nameLabel.backgroundColor = .clear
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white

        switch style {
        case .large:
            nameLabel.font = .systemFont(ofSize: Constants.largeNameFontSize)
        case .small:
            nameLabel.font = .systemFont(ofSize: Constants.smallNameFontSize)
        }
    }

    func setupViewHierarchies() {
        [
            emojiLabel,
            nameLabel
        ].forEach({
            addSubview($0)
        })
    }

    func setupViewConstraints() {
        emojiLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(emojiLabel)
            make.top.equalTo(emojiLabel.snp.bottom).offset(Constants.offset)
        }
    }
}
