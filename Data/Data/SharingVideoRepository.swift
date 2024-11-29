//
//  SharingVideoRepository.swift
//  Data
//
//  Created by Yune gim on 11/18/24.
//

import Combine
import Entity
import Foundation
import Interfaces
import P2PSocket
import Core


public final class SharingVideoRepository: SharingVideoRepositoryInterface {
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: SocketProvidable
    private let synchronizer = Synchronizer(
        folder: FileSystemManager.shared.folder)
    
    private var hasMismatch: Bool = false
    private var sendSyncFlags: [String: Bool] = [:]
    private var receiveSyncFlags: [String: Bool] = [:]
    private var allSynced: Bool {
        sendSyncFlags.values.allSatisfy { $0 } && receiveSyncFlags.values.allSatisfy { $0 }
    }

    public let updatedSharedVideo = PassthroughSubject<SharedVideo, Never>()
    public let isSynchronized = PassthroughSubject<Void, Never>()

    public init(socketProvider: SocketProvidable) {
        self.socketProvider = socketProvider
        socketProvider.resourceShared
            .compactMap { [weak self] resource in
                self?.mappingToSharedVideo(resource)
            }
            .subscribe(updatedSharedVideo)
            .store(in: &cancellables)
        
        socketProvider.dataShared
            .sink { [weak self] (data, peerID) in
                guard let self else { return }
                guard let data = try? JSONDecoder().decode(SyncMessage.self, from: data) else { return }
                switch data {
                case .hash(let hashes):
                    sendComparingResult(with: hashes, to: peerID)
                case .hashMatch(let result):
                    synchronize(with: result, to: peerID)
                    checkIfAllSynced()
                case .request(let fileNames):
                    sendFiles(fileNames: fileNames, to: peerID, isRequested: true)
                case .requestCompletionFlag:
                    receiveSyncFlags[peerID]  = true
                    checkIfAllSynced()
                case .completed:
                    isSynchronized.send(())
                }
            }
            .store(in: &cancellables)    
    }
}

// MARK: - Private Methods
private extension SharingVideoRepository {
    func mappingToSharedVideo(_ resource: SharedResource) -> SharedVideo {
        return .init(localUrl: resource.localUrl, author: resource.sender)
    }
    
    func broadcastCompleted() {
        guard let completedMessage = try? JSONEncoder().encode(SyncMessage.completed) else { return }
        socketProvider.sendAll(data: completedMessage)
        isSynchronized.send(())
    }
    
    func sendComparingResult(with hashes: [String: String], to peerID: String) {
        let result = synchronizer.compareToLocal(with: hashes)
        let hashMessage = SyncMessage.hashMatch(result)
        
        guard let serializedData = try? JSONEncoder().encode(hashMessage) else { return }
        socketProvider.send(data: serializedData, to: peerID)
    }
    
    func synchronize(with result: [String: HashCondition], to peerID: String) {
        if result.isEmpty {
            sendSyncFlags[peerID] = true
            receiveSyncFlags[peerID] = true
            return
        }
        
        hasMismatch = true
        
        let missingFiles = result.filter { $0.value == .missing }.map { $0.key }
        let additionalFiles = result.filter { $0.value == .additional }.map { $0.key }
        
        sendFiles(fileNames: missingFiles, to: peerID, isRequested: false)
        requestFiles(fileNames: additionalFiles, to: peerID)
    }
    
    func sendFiles(fileNames: [String], to peerID: String, isRequested: Bool) {
        guard !fileNames.isEmpty else {
            sendSyncFlags[peerID] = true
            return
        }
        
        Task {
            for index in fileNames.indices {
                let fileName = fileNames[index]
                let fileURL = FileSystemManager.shared.folder.appending(component: fileName)
                
                await socketProvider.sendResource(url: fileURL,
                                                  resourceName: fileName,
                                                  to: peerID)
                sendSyncFlags[peerID] = true
            }
            
            if isRequested {
                sendRequestResponse(to: peerID)
            }
        }
    }
    
    func requestFiles(fileNames: [String], to peerID: String) {
        guard !fileNames.isEmpty else {
            receiveSyncFlags[peerID] = true
            return
        }
        
        let request = SyncMessage.request(fileNames)
        guard let requestData = try? JSONEncoder().encode(request) else { return }
        socketProvider.send(data: requestData, to: peerID)
    }
    
    func sendRequestResponse(to peerID: String) {
        let receivedFlag = SyncMessage.requestCompletionFlag
        guard let data = try? JSONEncoder().encode(receivedFlag) else { return }
        self.socketProvider.send(data: data, to: peerID)
    }
    
    func checkIfAllSynced() {
        if allSynced {
            if hasMismatch {
                broadcastHashes()
            } else {
                broadcastCompleted()
            }
        }
    }
}

// MARK: - Public Methods
public extension SharingVideoRepository {
    func shareVideo(url: URL, resourceName: String) async throws {
        try await socketProvider.sendResourceToAll(url: url, resourceName: resourceName)
    }
    
    func fetchVideos() -> [SharedVideo] {
        socketProvider.sharedAllResources()
            .compactMap { [weak self] resource in
                self?.mappingToSharedVideo(resource)
            }
    }
    
    func broadcastHashes() {
        let collectedHashes = synchronizer.collectHashes()
        let hashMessage = SyncMessage.hash(collectedHashes)
        
        guard let encodedData = try? JSONEncoder().encode(hashMessage) else { return }
        socketProvider.sendAll(data: encodedData)
        for peer in socketProvider.connectedPeers().filter({ $0.state == .connected || $0.state == .pending }).map({ $0.id }) {
            sendSyncFlags[peer] = false
            receiveSyncFlags[peer] = false
        }
        hasMismatch = false
    }
}

extension SharingVideoRepository {
    enum SyncMessage: Codable {
        case hash([String: String])
        case hashMatch([String: HashCondition])
        case request([String])
        case requestCompletionFlag
        case completed
    }

}
