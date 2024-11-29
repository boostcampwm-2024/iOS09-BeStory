//
//  ImageFrameView.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import UIKit
import SnapKit

final class ImageFrameView: UIImageView {
	private let blurView = ImageFrameBlurView()
	
	var selectedRect: CGRect = .zero {
		didSet { blurView.selectedRect = selectedRect }
	}
	
	// MARK: - Initializers
	init() {
		super.init(frame: .zero)
		setupUI()
		isUserInteractionEnabled = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - UI Methods
private extension ImageFrameView {
	func setupUI() {
		setupViewHierarchies()
		setupViewConstraints()
		setupViewAttributes()
	}
	
	func setupViewAttributes() {
		self.backgroundColor = .systemBackground
	}
	
	func setupViewHierarchies() {
		addSubview(blurView)
	}
	
	func setupViewConstraints() {
		blurView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
