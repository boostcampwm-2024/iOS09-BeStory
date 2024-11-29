//
//  FileSystemManager.swift
//  Feature
//
//  Created by 디해 on 11/15/24.
//

import CryptoKit
import Foundation

public final class FileSystemManager {
    public static let shared = FileSystemManager()

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
    
    public func copyToFileSystem(tempURL: URL, resourceName: String? = nil) -> URL? {
        var originalFileName = resourceName ?? tempURL.lastPathComponent
        if !originalFileName.hasSuffix(".mp4") {
            originalFileName += ".mp4"
        }
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
    
    public func collectHashes() -> [String: String] {
        var fileHashes = [String: String]()
        
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        ) else { return [:] }
        for fileURL in fileURLs {
            guard let hash = calculateFileHash(for: fileURL) else { return [:] }
            fileHashes[fileURL.lastPathComponent] = hash
        }
        
        return fileHashes
    }
    
    private func calculateFileHash(for fileURL: URL) -> String? {
        guard let fileData = try? Data(contentsOf: fileURL) else { return nil }
        let hash = SHA256.hash(data: fileData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
