//
//  UIImage+Concat.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import UIKit

extension Array where Element: UIImage {
	func concatImagesHorizontaly() -> UIImage {
		let maxWidth = self.compactMap { $0.size.width }.max() ?? 0
		let maxHeight = self.compactMap { $0.size.height }.max() ?? 0
		
		let singleSize = CGSize(width: maxWidth, height: maxHeight)
		let totalSize = CGSize(width: maxWidth * (CGFloat)(self.count), height: maxHeight)
		let render = UIGraphicsImageRenderer(size: totalSize)
		
		return render.image { _ in
			for (index, image) in self.enumerated() {
				let rect = CGRect(
					x: singleSize.width * CGFloat(index),
					y: 0,
					width: singleSize.width,
					height: singleSize.height
				)
				
				image.draw(in: rect)
			}
		}
	}
}
