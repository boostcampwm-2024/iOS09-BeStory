//
//  ReadOnlyPublisher.swift
//  Feature
//
//  Created by 디해 on 11/11/24.
//

import Foundation
import Combine

public struct ReadOnlyPublisher<T> {
    private let subject: CurrentValueSubject<T, Never>
    
    public init(_ initialValue: T) {
        subject = CurrentValueSubject(initialValue)
    }
    
    public var publisher: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public var value: T {
        subject.value
    }
    
    func send(_ newValue: T) {
        subject.send(newValue)
    }
}
