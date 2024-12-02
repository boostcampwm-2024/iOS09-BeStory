//
//  RoundButton.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import UIKit

class RoundButton: UIButton {
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.bounds.height / 2
	}
}
