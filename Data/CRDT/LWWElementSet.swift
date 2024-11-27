//
//  LWWElementSet.swift
//  Data
//
//  Created by 이숲 on 11/27/24.
//

import Foundation

public actor LWWElementSet<T: Hashable> {
    private var additions: [T: Timestamp] = [:]
    private var removals: [T: Timestamp] = [:]

    public func add(element: T, timestamp: Timestamp) {
        if let existingTimestamp = self.additions[element], existingTimestamp >= timestamp {
            return
        }
        self.additions[element] = timestamp

    }

    public func remove(element: T, timestamp: Timestamp) {
        if let existingTimestamp = self.removals[element], existingTimestamp >= timestamp {
            return
        }
        self.removals[element] = timestamp

    }

    public func merge(with otherSet: LWWElementSet<T>) async {
        let otherAdditions = await otherSet.additions
        let otherRemovals = await otherSet.removals

        for (element, timestamp) in otherAdditions {
            self.add(element: element, timestamp: timestamp)
        }

        for (element, timestamp) in otherRemovals {
            self.remove(element: element, timestamp: timestamp)
        }

    }

    public func elements() -> [T] {
        var result: [T] = []

        for (element, addTimestamp) in additions {
            if let removeTimestamp = removals[element], removeTimestamp >= addTimestamp {
                continue
            }
            result.append(element)
        }

        return result
    }
}
