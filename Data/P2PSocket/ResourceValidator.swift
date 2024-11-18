//
//  ResourceValidator.swift
//  P2PSocket
//
//  Created by Yune gim on 11/18/24.
//

import Foundation
import RegexBuilder

struct ResourceValidator {
    static func extractInformation(name: String) -> (String, UUID)? {
        let regex = Regex {
            Capture {
                OneOrMore(.any)
            }
            "/"
            Capture {
                OneOrMore(.any)
            }
        }
        
        guard let output = name.wholeMatch(of: regex) else { return nil }
        let (_, fileNameOutput, uuidOutput) = output.output
        
        guard let uuid = UUID(uuidString: String(uuidOutput)) else { return nil }
        let fileName = String(fileNameOutput)
        
        return (fileName, uuid)
    }
}
