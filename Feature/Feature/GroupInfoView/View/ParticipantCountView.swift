//
//  ParticipantCountView.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import SnapKit
import UIKit

class ParticipantCountView: UIView {
    let groupImageView = UIImageView()
    let countLabel = UILabel()
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
        backgroundColor = .green
        groupImageView.image = UIImage(systemName: "person.2.wave.2.fill")
        countLabel.text = "\(userCount)"
    }
}
