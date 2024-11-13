//
//  ViewModelable.swift
//  Feature
//
//  Created by 이숲 on 11/11/24.
//

import Combine

protocol ViewModelable {
    associatedtype Input
    associatedtype Output

    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
