//
//  UIButton+BSReactive.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import UIKit

extension BeStoryReactive where Base: UIButton {
	var tap: UIControl.EventPublisher {
		base.publisher(for: .touchUpInside)
	}
}
