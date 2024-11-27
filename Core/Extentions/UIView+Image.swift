//
//  UIView+Image.swift
//  Core
//
//  Created by Yune gim on 11/27/24.
//

import UIKit

public extension UIView {
  func toImage() -> UIImage {
    return UIGraphicsImageRenderer(size: bounds.size).image { _ in
      drawHierarchy(in: bounds, afterScreenUpdates: true)
    }
  }
}
