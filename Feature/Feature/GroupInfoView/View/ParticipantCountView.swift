//
//  ParticipantCountView.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import SnapKit
import UIKit

final class ParticipantCountView: UIView {
    private let groupImageView = UIImageView()
    private let countLabel = UILabel()
    private var userCount: Int
    
    init(count: Int) {
        userCount = count
        super.init(frame: .zero)
        setupViewHierarchies()
        setupViewConstraints()
        setupViewAttributes()
    }
    
    convenience init() {
        self.init(count: 0)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init with XIB not supported")
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 20)
    }
    
    func updateCount(to count: Int) {
        userCount = count
        countLabel.text = "\(count)"
    }
}

private extension ParticipantCountView {
    func setupViewHierarchies() {
        addSubview(groupImageView)
        addSubview(countLabel)
    }
    
    func setupViewConstraints() {
        groupImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        countLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(groupImageView.snp.trailing).offset(8)
        }
    }
    
    func setupViewAttributes() {
        let tintColor = UIColor(red: 134/255, green: 141/255, blue: 154/255, alpha: 1)
        groupImageView.image = UIImage(systemName: "person.2.wave.2.fill")?
            .withTintColor(tintColor, renderingMode: .alwaysOriginal)
        countLabel.text = "\(userCount)"
        countLabel.textColor = tintColor
    }
}
