//
//  EditOptionView.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import Combine
import UIKit
import SnapKit

final class OptionButtonStackView: UIStackView {
	// MARK: - UI Components
	fileprivate let videoTrimmingButton = EditOptionButton(icon: .init(systemName: "clock"))
	
	// MARK: - Initializers
	init() {
		super.init(frame: .zero)
		setupUI()
	}
	
	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - UI Methods
private extension OptionButtonStackView {
	func setupUI() {
		setupViewAttribtues()
		setupViewHierarchies()
	}
	
	func setupViewAttribtues() {
		spacing = 12
		distribution = .fillEqually
		alignment = .leading
		axis = .horizontal
	}
	
	func setupViewHierarchies() {
		addArrangedSubview(videoTrimmingButton)
	}
}

// MARK: - BeStoryReactive
extension BeStoryReactive where Base: OptionButtonStackView {
	var videoTrimmingButtonDidTapped: UIControl.EventPublisher {
		base.videoTrimmingButton.bs.tap
	}
}
