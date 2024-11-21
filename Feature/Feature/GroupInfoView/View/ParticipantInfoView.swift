//
//  ParticipantInfoView.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import SnapKit
import UIKit
import Entity

final class ParticipantInfoView: UIView {
    private let profileEmojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let stateIndicatorView = UIView()
    
    let user: ConnectedUser
    
    init(user: ConnectedUser, emoji: String?) {
        self.user = user
        super.init(frame: .zero)
        setupViewHierarchies()
        setupViewConstraints()
        setupViewAttributes()
        backgroundColor = UIColor(
            red: 31/255,
            green: 41/255,
            blue: 55/255,
            alpha: 1
        )
        profileEmojiLabel.text = emoji
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init with XIB not supported")
    }
    
    func updateState(_ state: ConnectedUser.State) {
        setupStateIndicator(to: state)
    }
}

private extension ParticipantInfoView {
    func setupViewHierarchies() {
        addSubview(profileEmojiLabel)
        addSubview(nameLabel)
        addSubview(stateIndicatorView)
    }
    
    func setupViewConstraints() {
        profileEmojiLabel.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileEmojiLabel.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
        }
        stateIndicatorView.snp.makeConstraints {
            $0.width.height.equalTo(8)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
    
    func setupViewAttributes() {
        layer.cornerRadius = 12
//        profileEmojiLabel.backgroundColor = .black
        setupName(to: user.name)
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .white
        setupStateIndicator(to: user.state)
        stateIndicatorView.layer.cornerRadius = 4
    }
    
    func setupName(to name: String) {
        nameLabel.text = name
    }
    
    func setupStateIndicator(to state: ConnectedUser.State) {
        switch state {
        case .connected:
            stateIndicatorView.backgroundColor = .systemGreen
        case .disconnected:
            stateIndicatorView.backgroundColor = .systemGray6
        case .pending:
            stateIndicatorView.backgroundColor = .systemRed
        }
    }
}
