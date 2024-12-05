//
//  URL+Extension.swift
//  P2PSocket
//
//  Created by jung on 12/3/24.
//

import Foundation

public extension URL {
    func append(author: String) -> URL {
        let queryItem = URLQueryItem(name: "author", value: author)
        return appending(queryItems: [queryItem])
    }
    
    func author() -> String {
        guard let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems else { return "" }
        
        return queryItems.first { $0.name == "author" }?.value ?? ""
    }
    
    func resourceName() -> String {
        return (path as NSString).lastPathComponent
    }
}
