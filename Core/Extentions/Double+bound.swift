//
//  Double+bound.swift
//  Core
//
//  Created by jung on 11/30/24.
//

public extension Double {
	func bound(lower: Double, upper: Double) -> Double {
		return min(max(self, lower), upper)
	}
}
