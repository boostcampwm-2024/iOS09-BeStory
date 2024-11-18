//
//  Counter.swift
//  P2PSocket
//
//  Created by Yune gim on 11/18/24.
//

import Foundation
import Combine

actor Counter: NSObject {
    private let targetNumber: Int
    let completPublisher = CurrentValueSubject<Int, Error>(0)
    var currentNumber: Int = 0
    
    init(targetCount: Int) {
        self.targetNumber = targetCount
    }
    
    func increaseNumber() {
        currentNumber += 1
        completPublisher.send(currentNumber)
        guard currentNumber == targetNumber else { return }
        completPublisher.send(completion: .finished)
    }
}
