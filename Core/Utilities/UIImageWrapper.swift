//
//  UIImageWrapper.swift
//  Core
//
//  Created by jung on 12/1/24.
//

import UIKit

public struct UIImageWrapper {
	public let image: UIImage
	
	public init(image: UIImage) {
		self.image = image
	}
	
	public init() {
		self.init(image: UIImage())
	}
}
