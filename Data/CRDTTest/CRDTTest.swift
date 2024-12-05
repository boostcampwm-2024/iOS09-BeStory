//
//  CRDTTest.swift
//  CRDTTest
//
//  Created by Yune gim on 11/29/24.
//

import CRDT
import XCTest

final class CRDTTest: XCTestCase {
    func testIsLWWElementSetStateCodable() async throws {
        let peer0ID = UUID().uuidString
        let peer1ID = UUID().uuidString
        let peer0 = LWWElementSet<Int>(id: peer0ID, peerIDs: [peer1ID])
        let peer1 = LWWElementSet<Int>(id: peer1ID, peerIDs: [peer0ID])
        
        let encoder = JSONEncoder()
        let peer0event = await peer0.localAdd(element: 0)
        let peer1event = await peer1.localAdd(element: 4)
        
        let peer0data = try encoder.encode(peer0event)
        let peer1data = try encoder.encode(peer1event)
        
        let decoder = JSONDecoder()
        let peer0state = try decoder.decode(LWWElementSetState<Int>.self, from: peer0data)
        let peer1state = try decoder.decode(LWWElementSetState<Int>.self, from: peer1data)
        
        XCTAssertEqual(peer0event, peer0state)
        XCTAssertEqual(peer1event, peer1state)
    }
    
    func testIsMergeCompletWhenEventArrivedRandomly() async {
        let peer0ID = UUID().uuidString
        let peer1ID = UUID().uuidString
        let peer2ID = UUID().uuidString

        let peer0 = LWWElementSet<Int>(id: peer0ID, peerIDs: [peer1ID, peer2ID])
        let peer1 = LWWElementSet<Int>(id: peer1ID, peerIDs: [peer0ID, peer2ID])
        let peer2 = LWWElementSet<Int>(id: peer2ID, peerIDs: [peer0ID, peer1ID])
        
        let peer0event0 = await peer0.localAdd(element: 0)
        let peer0event1 = await peer0.localAdd(element: 4)
        let peer0event2 = await peer0.localAdd(element: 5)
        let peer0event3 = await peer0.localAdd(element: 8)
        
        let randomlyOrderdEventP0 = [
            peer0event0,
            peer0event1,
            peer0event2,
            peer0event3
        ].shuffled()
        for state in randomlyOrderdEventP0 {
            await peer1.merge(with: state)
        }
        
        let peer1element = await peer1.elements()
        XCTAssertEqual(Set(peer1element), Set([0, 4, 5, 8]))
        
        let peer1event = await peer1.localAdd(element: 10)
        
        let randomlyOrderdEvent = [
            peer1event,
            peer0event3,
            peer0event1,
            peer0event0,
            peer0event2
        ].shuffled()
        for state in randomlyOrderdEvent {
            await peer2.merge(with: state)
        }
        
        let peer2element = await peer2.elements()
        XCTAssertEqual(Set(peer2element), Set([0, 4, 5, 8, 10]))
    }
    
    func testIsMergeLastWriterWins() async throws {
        let peer0ID = UUID().uuidString
        let peer1ID = UUID().uuidString
        let peer0 = LWWElementSet<LWWDummy>(id: peer0ID, peerIDs: [peer1ID])
        let peer1 = LWWElementSet<LWWDummy>(id: peer1ID, peerIDs: [peer0ID])
        
        let peer0data = LWWDummy(data: 1, author: "p0")
        let peer1data = LWWDummy(data: 1, author: "p1")
        
        let peer0event = await peer0.localAdd(element: peer0data)
        await peer1.merge(with: peer0event)
        
        let peer1event1 = await peer1.localAdd(element: peer1data)
        await peer0.merge(with: peer1event1)

        let peer0element = await peer0.elements()
        let peer1element = await peer1.elements()

        XCTAssertEqual(peer0element, peer1element)
        XCTAssertEqual(peer0element.first?.author, "p1")
        XCTAssertEqual(peer1element.first?.author, "p1")
    }
}

struct LWWDummy: Hashable, Codable {
    let data: Int
    let author: String
    
    static func == (lhs: LWWDummy, rhs: LWWDummy) -> Bool {
        return lhs.data == rhs.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}
