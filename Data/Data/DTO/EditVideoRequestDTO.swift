//
//  EditVideoRequestDTO.swift
//  Data
//
//  Created by jung on 12/2/24.
//

import Foundation

struct EditVideoDTO: Codable {
    let editingType: EditingType
    let url: URL
    let index: Int
    let name: String
    let author: String
    let duration: Double
    let startTime: Double
    let endTime: Double
}
