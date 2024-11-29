//
//  UIImage+converColor.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import UIKit

extension UIImage {
  func color(_ color: UIColor) -> UIImage {
	return self.withTintColor(color, renderingMode: .alwaysOriginal)
  }
}
