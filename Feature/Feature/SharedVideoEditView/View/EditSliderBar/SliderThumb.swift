//
//  SliderThumb.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import UIKit
import SnapKit

final class SliderThumb: UIView {
	// MARK: - UI Components
	private let imageView = UIImageView()
	
	// MARK: - Properties
	var isHightlighted: Bool = false {
		didSet { setupUI(for: isHightlighted) }
	}
	
	var thumbTintColor: UIColor {
		didSet { setupUI(for: isHightlighted) }
	}
	
	var hightlightedThumbColor: UIColor {
		didSet { setupUI(for: isHightlighted) }
	}
	
	// MARK: - Initializers
	init(trackTintColor: UIColor, hightlightedTintColor: UIColor) {
		self.thumbTintColor = trackTintColor
		self.hightlightedThumbColor = hightlightedTintColor

		super.init(frame: .zero)
		isUserInteractionEnabled = false
		setupUI()
	}
	
	convenience init(tintColor: UIColor) {
		self.init(trackTintColor: tintColor, hightlightedTintColor: tintColor)
	}
	
	convenience init() {
		self.init(trackTintColor: .clear, hightlightedTintColor: .clear)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - LayoutSubviews
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = self.bounds.width / 2
	}
}

// MARK: - UI Methods
private extension SliderThumb {
	func setupUI() {
		setupViewHierarchies()
		setupViewConstraints()
		setupViewAttributes()
		setupImageView()
	}
	
	func setupViewHierarchies() {
		addSubview(imageView)
	}
	
	func setupViewConstraints() {
		imageView.snp.makeConstraints {
			$0.top.bottom.equalToSuperview().inset(10)
			$0.leading.trailing.equalToSuperview().inset(4)
		}
	}
	
	func setupImageView() {
		imageView.contentMode = .scaleToFill
	}
	
	func setupViewAttributes() {
		self.backgroundColor = thumbTintColor
	}
	
	func setupUI(for isHighlighted: Bool) {
		self.backgroundColor = isHighlighted ? self.hightlightedThumbColor : self.thumbTintColor
	}
}

// MARK: - Internal Methods
extension SliderThumb {
	func contain(point: CGPoint) -> Bool {
		return frame.contains(point)
	}
	
	func setImage(_ image: UIImage?) {
		self.imageView.image = image
	}
}
