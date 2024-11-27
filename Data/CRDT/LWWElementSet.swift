//
//  LWWElementSet.swift
//  Data
//
//  Created by 이숲 on 11/27/24.
//

import Foundation

public final class LWWElementSet<T: Hashable> {
    private var additions: [T: Timestamp] = [:]
    private var removals: [T: Timestamp] = [:]
    private let queue = DispatchQueue(label: "crdt.queue", attributes: .concurrent)

    public func add(element: T, timestamp: Timestamp) {
        queue.async(flags: .barrier) {
            if let existingTimestamp = self.additions[element], existingTimestamp >= timestamp {
                return
            }
            self.additions[element] = timestamp
        }
    }

    public func remove(element: T, timestamp: Timestamp) {
        queue.async(flags: .barrier) {
            if let existingTimestamp = self.removals[element], existingTimestamp >= timestamp {
                return
            }
            self.removals[element] = timestamp
        }
    }

    public func merge(with otherSet: LWWElementSet<T>) {
        queue.async(flags: .barrier) {
            for (element, timestamp) in otherSet.additions {
                self.add(element: element, timestamp: timestamp)
            }
            for (element, timestamp) in otherSet.removals {
                self.remove(element: element, timestamp: timestamp)
            }
        }
    }

    public func elements() -> [T] {
        var result: [T] = []
        queue.sync {
            for (element, addTimestamp) in additions {
                if let removeTimestamp = removals[element], removeTimestamp >= addTimestamp {
                    continue
                }
                result.append(element)
            }
        }
        return result
    }
}
