//
//  Timestamp.swift
//  Data
//
//  Created by 이숲 on 11/27/24.
//

import Foundation

public struct Timestamp: Comparable {
    let replicaID: String
    let counter: Int
    let date: Date

    public init(
        replicaID: String,
        counter: Int,
        date: Date
    ) {
        self.replicaID = replicaID
        self.counter = counter
        self.date = date
    }

    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        if lhs.counter == rhs.counter {
            return lhs.date < rhs.date
        }

        return lhs.counter < rhs.counter
    }
}
