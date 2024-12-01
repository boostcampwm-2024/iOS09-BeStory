//
//  EditButton.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import UIKit

final class EditOptionButton: RoundButton {
	enum Constants {
		static let iconSize = CGSize(width: 20, height: 20)
	}
	
	// MARK: - Properties
	override var intrinsicContentSize: CGSize {
		return .init(width: 30, height: 30)
	}
	
	var icon: UIImage? {
		didSet { }
	}
	
	// MARK: - Initializers
	init(icon: UIImage?) {
		self.icon = icon
		super.init(frame: .zero)
		setupUI()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - UI Methods
private extension EditOptionButton {
	func setupUI() {
		setupAttributes()
		setIcon(icon: icon)
	}
	
	func setupAttributes() {
		backgroundColor = .init(hex: "f6f6f7")
	}
	
	func setIcon(icon: UIImage?) {
		guard let icon else { return }
		let image = icon.resize(Constants.iconSize).color(.black)
		
		setImage(image, for: .normal)
	}
}
