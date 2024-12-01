//
//  BeStoryCompatible.swift
//  Feature
//
//  Created by jung on 12/1/24.
//

import UIKit

struct BeStoryReactive<Base> {
	let base: Base
}

protocol BeStoryReactiveCompatible: AnyObject {}

extension BeStoryReactiveCompatible {
	// swiftlint:disable identifier_name
	var bs: BeStoryReactive<Self> { .init(base: self) }
	// swiftlint:enable identifier_name
}

extension UIView: BeStoryReactiveCompatible {}
