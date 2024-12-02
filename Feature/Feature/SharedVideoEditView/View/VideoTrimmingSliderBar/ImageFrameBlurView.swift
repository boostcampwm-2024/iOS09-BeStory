//
//  BlurView.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import UIKit

/// ImageFrame에서 Blur처리를 담당하는 View
final class ImageFrameBlurView: UIView {
	var selectedRect: CGRect = .zero {
		didSet { setNeedsDisplay() }
	}
	
	init() {
		super.init(frame: .zero)
		self.backgroundColor = .clear
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let context = UIGraphicsGetCurrentContext()	else { return }
		
		context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
		context.fill(bounds)
		
		context.setBlendMode(.clear)
		context.fill(selectedRect)
		
		context.setBlendMode(.normal)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
