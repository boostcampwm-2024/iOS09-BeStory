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
        if await mergeAvailableSet(with: otherSet) {
            return await mergeWatingSet()
        }
        waitSet.append(otherSet)
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

private extension LWWElementSet {
     func add(element: T, remoteClock: VectorClock) {
        if let clock = self.additions[element],
           clock >= remoteClock {
            return
        }
        self.additions[element] = remoteClock
    }

    func remove(element: T, remoteClock: VectorClock) {
        if let clock = self.removals[element],
           clock >= remoteClock {
            return
        }
        self.removals[element] = remoteClock
    }
    
    func clone() -> LWWElementSet {
        return LWWElementSet(
            id: id,
            clock: vectorClock,
            additions: additions,
            removals: removals,
            waitSet: waitSet
        )
    }
    
    func mergeWatingSet() async {
        var availableSet = [LWWElementSet]()
        repeat {
            while !availableSet.isEmpty {
                let set = availableSet.removeLast()
                await mergeAvailableSet(with: set)
            }
            for (index, set) in waitSet.enumerated()
            where await vectorClock.readyFor(replicaId: set.id, to: set.vectorClock) {
                availableSet.append(set)
                waitSet.remove(at: index)
            }
        } while !availableSet.isEmpty
    }
    
    @discardableResult
    func mergeAvailableSet(with otherSet: LWWElementSet<T>) async -> Bool {
        let remoteClock = await otherSet.vectorClock
        guard vectorClock.readyFor(replicaId: otherSet.id, to: remoteClock) else { return false }
        
        let otherAdditions = await otherSet.additions
        let otherRemovals = await otherSet.removals
        
        for (element, clock) in otherAdditions {
            self.add(element: element, remoteClock: clock)
        }
        for (element, clock) in otherRemovals {
            self.remove(element: element, remoteClock: clock)
        }
        
        vectorClock.increase(replicaId: otherSet.id)
        return true
    }
}
