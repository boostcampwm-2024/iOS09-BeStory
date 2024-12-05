//
//  FileSystemManager.swift
//  Feature
//
//  Created by 디해 on 11/15/24.
//

import Foundation

public final class FileSystemManager {
    public static let shared = FileSystemManager()
    public let folder: URL
    
    private let fileManager = FileManager.default
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
  
    public func mappingToLocalURL(url: URL, resourceName: String? = nil) -> URL? {
        var originalFileName = resourceName ?? url.lastPathComponent
        if !originalFileName.hasSuffix(".mp4") {
            originalFileName += ".mp4"
        }
        let destinationURL = folder.appending(path: originalFileName)
        
        guard fileManager.fileExists(atPath: destinationURL.path) else { return nil }
        return destinationURL
    }
    
    public func copyToFileSystem(tempURL: URL, resourceName: String? = nil) -> URL? {
        var originalFileName = resourceName ?? tempURL.lastPathComponent
        if !originalFileName.hasSuffix(".mp4") {
            originalFileName += ".mp4"
        }
        let destinationURL = folder.appending(path: originalFileName)
        guard !fileManager.fileExists(atPath: destinationURL.path) else { return nil }
        try? fileManager.copyItem(at: tempURL, to: destinationURL)
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
