//
//  Sequence+AsyncCompactMap.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

extension Sequence {
    func asyncCompactMap<T>(_ transform: (Element) async -> T?) async -> [T] {
        var results = [T]()
        for element in self {
            if let result = await transform(element) {
                results.append(result)
            }
        }
        return results
    }
}
