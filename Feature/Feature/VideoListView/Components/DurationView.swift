//
//  DurationView.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import UIKit
import SnapKit

final class DurationView: UIView {
    // MARK: - UI Components
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "C9C9C9")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        
        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with duration: String) {
        durationLabel.text = duration
    }
}

// MARK: - Setting
private extension DurationView {
    func setupViewAttributes() {
        layer.cornerRadius = 7
        backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    func setupViewHierarchies() {
        addSubview(durationLabel)
    }
    
    func setupViewConstraints() {
        durationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}
