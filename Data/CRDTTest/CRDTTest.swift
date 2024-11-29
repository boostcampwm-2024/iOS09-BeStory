//
//  CRDTTest.swift
//  CRDTTest
//
//  Created by Yune gim on 11/29/24.
//

import XCTest
import CRDT

final class CRDTTest: XCTestCase {
    func testIsLWWElementSetStateCodable() async throws {
        let peerCount = 2
        let p0 = LWWElementSet<Int>(id: 0, peerCount: peerCount)
        let p1 = LWWElementSet<Int>(id: 1, peerCount: peerCount)
        
        let encoder = JSONEncoder()
        let p0event = await p0.localAdd(element: 0)
        let p1event = await p1.localAdd(element: 4)
        
        let p0data = try encoder.encode(p0event)
        let p1data = try encoder.encode(p1event)
        
        let decoder = JSONDecoder()
        let p0state = try decoder.decode(LWWElementSetState<Int>.self, from: p0data)
        let p1state = try decoder.decode(LWWElementSetState<Int>.self, from: p1data)
        
        XCTAssertEqual(p0event, p0state)
        XCTAssertEqual(p1event, p1state)
    }
    
    func testIsMergeCompletWhenEventArrivedRandomly() async {
        let peerCount = 3
        let p0 = LWWElementSet<Int>(id: 0, peerCount: peerCount)
        let p1 = LWWElementSet<Int>(id: 1, peerCount: peerCount)
        let p2 = LWWElementSet<Int>(id: 2, peerCount: peerCount)
        
        let p0event0 = await p0.localAdd(element: 0)
        let p0event1 = await p0.localAdd(element: 4)
        let p0event2 = await p0.localAdd(element: 5)
        let p0event3 = await p0.localAdd(element: 8)
        
        let randomlyOrderdEventP0 = [p0event0, p0event1, p0event2, p0event3].shuffled()
        for state in randomlyOrderdEventP0 {
            await p1.merge(with: state)
        }
        
        let p1element = await p1.elements()
        XCTAssertEqual(Set(p1element), Set([0, 4, 5, 8]))
        
        let p1event = await p1.localAdd(element: 10)
        
        let randomlyOrderdEvent = [p1event, p0event3, p0event1, p0event0, p0event2].shuffled()
        for state in randomlyOrderdEvent {
            await p2.merge(with: state)
        }
        
        let p2element = await p2.elements()
        XCTAssertEqual(Set(p2element), Set([0, 4, 5, 8, 10]))
    }
    
    func testIsMergeLastWriterWins() async throws {
        let peerCount = 2
        let p0 = LWWElementSet<LWWDummy>(id: 0, peerCount: peerCount)
        let p1 = LWWElementSet<LWWDummy>(id: 1, peerCount: peerCount)
        
        let p0data = LWWDummy(data: 1, author: "p0")
        let p1data = LWWDummy(data: 1, author: "p1")
        
        let p0event = await p0.localAdd(element: p0data)
        await p1.merge(with: p0event)
        let p1event = await p0.localAdd(element: p1data)
        await p0.merge(with: p0event)

        let p0element = await p0.elements()
        let p1element = await p1.elements()

        XCTAssertEqual(p0element, p1element)
        XCTAssertEqual(p0element.first?.author, "p1")
        XCTAssertEqual(p1element.first?.author, "p1")
    }
}

struct LWWDummy: Hashable, Codable {
    let data: Int
    let author: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}
