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
    
    public let updatedElements = PassthroughSubject<[T], Never>()
    
    public init(id: Int, peerCount: Int) {
        self.id = id
        vectorClock = VectorClock(replicaCount: peerCount)
    }
    
    fileprivate init(
        id: Int,
        clock: VectorClock,
        additions: [T: VectorClock],
        removals: [T: VectorClock]
    ) {
        self.id = id
        self.vectorClock = clock
        self.additions = additions
        self.removals = removals
    }
}

public extension LWWElementSet {
    func localAdd(element: T) -> LWWElementSetState<T> {
        let clock = vectorClock.increase(replicaId: id)
        additions.removeValue(forKey: element)
        additions.updateValue(clock, forKey: element)
        return payloading()
    }
    
    func localRemove(element: T) -> LWWElementSetState<T> {
        let clock = vectorClock.increase(replicaId: id)
        removals.removeValue(forKey: element)
        removals.updateValue(clock, forKey: element)
        return payloading()
    }

    func merge(with state: LWWElementSetState<T>) async {
        let otherSet = state.excute()
        if await !mergeAvailableSet(with: otherSet) {
            return waitSet.append(otherSet)
        }
        return await mergeWatingSet()
    }

    func elements() -> [T] {
        var result: [T] = []
        
        for (element, clock) in additions {
            if let removeClock = removals[element], removeClock >= clock {
                continue
            }
            result.append(element)
        }
        return result
    }
}

private extension LWWElementSet {
    func mergeWatingSet() async {
        var availableSet = [LWWElementSet]()
        var completedSetIndexs = [Int]()
        repeat {
            while !availableSet.isEmpty {
                let set = availableSet.removeLast()
                await mergeAvailableSet(with: set)
            }
            for (index, set) in waitSet.enumerated()
            where await vectorClock.isPaasable(to: set.vectorClock, replicaId: set.id) {
                availableSet.append(set)
                completedSetIndexs.append(index)
            }
            while !completedSetIndexs.isEmpty {
                let index = completedSetIndexs.removeLast()
                waitSet.remove(at: index)
            }
        } while !availableSet.isEmpty
    }
    
    @discardableResult
    func mergeAvailableSet(with otherSet: LWWElementSet<T>) async -> Bool {
        let remoteClock = await otherSet.vectorClock
        guard vectorClock.isPaasable(to: remoteClock, replicaId: otherSet.id) else { return false }
        
        let otherAdditions = await otherSet.additions
        let otherRemovals = await otherSet.removals
        
        otherAdditions.forEach { add(element: $0, remoteClock: $1) }
        otherRemovals.forEach { remove(element: $0, remoteClock: $1) }
        
        updatedElements.send(elements())
        vectorClock.increase(replicaId: otherSet.id)
        return true
    }
    
    func add(element: T, remoteClock: VectorClock) {
        if let clock = additions[element], remoteClock <= clock { return }
        
        additions.removeValue(forKey: element)
        additions.updateValue(remoteClock, forKey: element)
    }
    
    func remove(element: T, remoteClock: VectorClock) {
        if let clock = removals[element], remoteClock <= clock { return }
        
        removals.removeValue(forKey: element)
        removals.updateValue(remoteClock, forKey: element)
    }
    
    func payloading() -> LWWElementSetState<T> {
        return LWWElementSetState(
            id: id,
            clock: vectorClock,
            additions: additions,
            removals: removals
        )
    }
}

public struct LWWElementSetState <T: Codable & Hashable> {
    fileprivate let id: Int
    fileprivate var vectorClock: VectorClock
    
    fileprivate var additions: [T: VectorClock] = [:]
    fileprivate var removals: [T: VectorClock] = [:]
    
    fileprivate init(
        id: Int,
        clock: VectorClock,
        additions: [T: VectorClock],
        removals: [T: VectorClock]
    ) {
        self.id = id
        self.vectorClock = clock
        self.additions = additions
        self.removals = removals
    }
}

fileprivate extension LWWElementSetState {
    func excute() -> LWWElementSet<T> {
        return LWWElementSet(
            id: id,
            clock: vectorClock,
            additions: additions,
            removals: removals
        )
    }
}

extension LWWElementSetState: Codable {
    enum CodingKeys: CodingKey {
        case id, vectorClock, additions, removals
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        vectorClock = try values.decode(VectorClock.self, forKey: .vectorClock)
        additions = try values.decode([T: VectorClock].self, forKey: .additions)
        removals = try values.decode([T: VectorClock].self, forKey: .removals)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(vectorClock, forKey: .vectorClock)
        try container.encode(additions, forKey: .additions)
        try container.encode(removals, forKey: .removals)
    }
}

extension LWWElementSetState: Equatable { }
