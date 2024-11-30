//
//  VectorClock.swift
//  CRDT
//
//  Created by Yune gim on 11/28/24.
//

import Foundation

struct VectorClock {
    var clock = [Int: Int]()
    
    init(replicaCount: Int) {
        clock = (0..<replicaCount).reduce(into: [Int: Int]()) { clock, replicaId in
            clock[replicaId] = 0
        }
    }
    
    subscript(replicaId replica: Int) -> Int {
        get {
            return clock[replica, default: 0]
        }
        set {
            clock[replica] = newValue
        }
    }
}

extension VectorClock {
    /// 해당 벡터 시계가 병합 가능한 벡터시계인지를 반환
    ///
    /// upstream 레플리카가 전송한 시계가 하기 두 사항을 만족해야 병합 가능
    /// - upstream의 레플리카에 대한 count - 1 == downstream의 벡터시계 중 해당 레플리카에 대한 count
    /// - upstream의 나머지 레플리카에 대한 count  <= downstream의 벡터 시계 중 나머지 레플리카에 대한 count
    func readyFor(replicaId replica: Int, to vectorClock: VectorClock) -> Bool {
        guard self[replicaId: replica] == vectorClock.clock[replica]! - 1 else { return false }
        for (replicaId, remoteCount) in vectorClock.clock {
            let localClockCont = self[replicaId: replicaId]
            if replica != replicaId && remoteCount > localClockCont {
                return false
            }
        }
        return true
    }
    
    /// 레플리카ID에 대한 시계눈금을 1만큼 증가
    @discardableResult
    mutating func increase(replicaId: Int) -> VectorClock {
        clock[replicaId, default: 0] += 1
        return self
    }
}

extension VectorClock: Comparable {
    static func < (lhs: VectorClock, rhs: VectorClock) -> Bool {
        if lhs > rhs {
            return false
        }
        if lhs == rhs {
            return false
        }
        return true
    }
    
    /// VectorClock > T인지를 반환
    /// 모든 레플리카 i에 대해 두 벡터시계를 v, v'라 하면
    /// v[i] > v'[i],
    static func > (lhs: VectorClock, rhs: VectorClock) -> Bool {
        var greaterThan = false
        for (key, value) in rhs.clock {
            if lhs[replicaId: key] < value {
                return false
            } else if lhs[replicaId: key] > value {
                greaterThan = true
            }
        }
        if greaterThan { return true }
        for (key, value) in lhs.clock where rhs[replicaId: key] < value {
            return true
        }
        return false
    }
    
    static func == (lhs: VectorClock, rhs: VectorClock) -> Bool {
        let keys = Set(lhs.clock.keys).union(rhs.clock.keys)
        for key in keys where lhs[replicaId: key] != rhs[replicaId: key] {
            return false
        }
        return true
    }
}

extension VectorClock: Codable { }
