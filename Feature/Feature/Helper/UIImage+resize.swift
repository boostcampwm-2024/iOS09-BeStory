//
//  UIImage+resize.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import UIKit

extension UIImage {
	/// 지정한 size로 image를 resize한 `UIImage`객체를 리턴합니다.
	/// - Parameters:
	///   - size: resize할 size
	func resize(_ size: CGSize) -> UIImage {
		let image = UIGraphicsImageRenderer(size: size).image { _ in
			draw(in: CGRect(origin: .zero, size: size))
		}
		
		return image.withRenderingMode(renderingMode)
	}
}
