//
//  CGPoint+Extension.swift
//  Feature
//
//  Created by 이숲 on 11/7/24.
//

import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
