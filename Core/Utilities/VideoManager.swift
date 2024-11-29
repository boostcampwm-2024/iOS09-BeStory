//
//  VideoManager.swift
//  Feature
//
//  Created by 디해 on 11/15/24.
//

import Foundation

public final class VideoManager {
    public static let shared = VideoManager()

    private let fileManager = FileManager.default
    private let folder: URL
    private let folderName: String = "videos"
    
    private init() {
        folder = fileManager.temporaryDirectory.appending(path: folderName)
        initializeDirectory()
    }
    
    private func initializeDirectory() {
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
    }
    
    public func copyVideoToFileSystem(tempURL: URL) -> URL? {
        let originalFileName = tempURL.lastPathComponent
        let destinationURL = folder.appending(path: originalFileName)
        if !fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.copyItem(at: tempURL, to: destinationURL)
        }
        return destinationURL
    }
    
    public func deleteAllFiles() {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        ) else { return }
        fileURLs.forEach { url in
            try? fileManager.removeItem(at: url)
        }
    }
}
