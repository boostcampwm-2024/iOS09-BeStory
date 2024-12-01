//
//  Combine+withUnretainedSink.swift
//  Core
//
//  Created by jung on 12/1/24.
//

import Combine

public extension Publisher {
	func sink<Object: AnyObject>(
		with object: Object,
		onCompletion: @escaping ((Object, Subscribers.Completion<Self.Failure>) -> Void),
		onReceive: @escaping ((Object, Self.Output) -> Void)
	) -> AnyCancellable {
		self.sink { [weak object] onCompleted in
			guard let object else { return }
			onCompletion(object, onCompleted)
		} receiveValue: { [weak object] value in
			guard let object else { return }
			onReceive(object, value)
		}
	}
	
	func sink<Object: AnyObject>(
		with object: Object,
		onReceive: @escaping ((Object, Self.Output) -> Void)
	) -> AnyCancellable {
		self.sink(
			receiveCompletion: { _ in
			},
			receiveValue: { [weak object] value in
				guard let object else { return }
				onReceive(object, value)
			}
		)
	}
}
