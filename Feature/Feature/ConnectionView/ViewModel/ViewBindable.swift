//
//  ViewBindable.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Foundation

protocol ViewBindable {
    associatedtype Output

    func setupBind()
}
