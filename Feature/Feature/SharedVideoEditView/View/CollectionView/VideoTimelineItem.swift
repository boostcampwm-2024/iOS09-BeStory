//
//  VideoTimelineItem.swift
//  Feature
//
//  Created by 이숲 on 11/28/24.
//

import Foundation

struct VideoTimelineItem: Codable, Hashable {
    let identifier = UUID()
    let thumbnailImage: Data
    let duration: String

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension VideoTimelineItem {
    static func fromJSONString(_ jsonString: String) -> VideoTimelineItem? {
        let decoder = JSONDecoder()
        guard let jsonData = jsonString.data(using: .utf8),
              let item = try? decoder.decode(VideoTimelineItem.self, from: jsonData) else { return nil }
        return item
    }
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}
