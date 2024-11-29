//
//  UIView+Extension.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import UIKit

public extension UIView {
  /// view의 identifier  (ex: `MyView.identifier`)
  static var identifier: String {
	String(describing: self)
  }
  
  
  /// 여러개의 subview들을 view에 추가합니다.
  /// - Parameter views: 추가할 subViews (ex: `view.addSubviews(view1, view2, view3)`)
  func addSubviews(_ views: UIView...) {
	views.forEach { addSubview($0) }
  }
}


