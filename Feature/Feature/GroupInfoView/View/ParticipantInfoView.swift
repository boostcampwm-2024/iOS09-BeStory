//
//  ParticipantInfoView.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import SnapKit
import UIKit

final class ParticipantInfoView: UIView {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let stateIndicatorView = UIView()
    
    private var user: InvitedUser
    
    init(user: InvitedUser) {
        self.user = user
        super.init(frame: .zero)
        setupViewHierarchies()
        setupViewConstraints()
        setupViewAttributes()
        backgroundColor = .green
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init with XIB not supported")
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 86, height: 35)
    }
    
    @discardableResult
    func updateState(user: InvitedUser) -> Bool {
        guard self.user.id == user.id else { return false }
        self.user = user
        setupStateIndicator(to: user.state)
        return true
    }
}

private extension ParticipantInfoView {
    func setupViewHierarchies() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(stateIndicatorView)
    }
    
    func setupViewConstraints() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(6)
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
        profileImageView.backgroundColor = .black
        setupName(to: user.name)
        setupStateIndicator(to: user.state)
        stateIndicatorView.layer.cornerRadius = 4
    }
    
    func setupName(to name: String) {
        nameLabel.text = name
    }
    
    func setupStateIndicator(to state: InvitedUser.ConnectState) {
        switch state {
        case .connected: stateIndicatorView.backgroundColor = .systemGreen
        case .connecting: stateIndicatorView.backgroundColor = .systemGray6
        default: stateIndicatorView.backgroundColor = .systemRed
        }
    }
}
