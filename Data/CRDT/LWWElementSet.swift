//
//  LWWElementSet.swift
//  Data
//
//  Created by 이숲 on 11/27/24.
//

import Combine

public actor LWWElementSet<T: Codable & Hashable> {
    private let id: Int
    private var vectorClock: VectorClock
    
    private var additions: [T: VectorClock] = [:]
    private var removals: [T: VectorClock] = [:]
    private var waitSet: [LWWElementSet] = []
        
    public init(id: Int, peerCount: Int) {
        self.id = id
        vectorClock = VectorClock(replicaCount: peerCount)
    }
    
    private init(id: Int,
                 clock: VectorClock,
                 additions: [T: VectorClock],
                 removals: [T: VectorClock],
                 waitSet: [LWWElementSet]
    ) {
        self.id = id
        self.vectorClock = clock
        self.additions = additions
        self.removals = removals
        self.waitSet = waitSet
    }
}

extension LWWElementSet {
    @discardableResult
    public func localAdd(element: T) -> LWWElementSet {
        let clock = vectorClock.increase(replicaId: id)
        additions[element] = clock
        return clone()
    }
    
    @discardableResult
    public func localRemove(element: T) -> LWWElementSet {
        let clock = vectorClock.increase(replicaId: id)
        removals[element] = clock
        return clone()
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
