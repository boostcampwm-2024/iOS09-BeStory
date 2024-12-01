//
//  UIStackView+AddArangeSubViews.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import UIKit

public extension UIStackView {
	/// stack view에 여러개의 subview들을 추가합니다.
	/// - Parameter views: 추가할 subViews (ex: `view.addArrangedSubviews(view1, view2, view3)`)
	func addArrangedSubviews(_ views: UIView...) {
		views.forEach { addArrangedSubview($0) }
	}
}
