//
//  SharingVideoRepository.swift
//  Data
//
//  Created by Yune gim on 11/18/24.
//

import Combine
import Core
import Entity
import Foundation
import Interfaces
import P2PSocket

public final class SharingVideoRepository: SharingVideoRepositoryInterface {
    public typealias SharingVideoSocketProvidable = SocketDataSendable & SocketResourceSendable & SocketBrowsable
    
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: SharingVideoSocketProvidable
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
    
    public init(socketProvider: SharingVideoSocketProvidable) {
        self.socketProvider = socketProvider
        socketProvider.resourceShared
            .compactMap { resource in
                DataMapper.mappingToSharedVideo(resource)
            }
            .subscribe(updatedSharedVideo)
            .store(in: &cancellables)
        
        socketProvider.dataShared
            .sink { [weak self] (data, peerID) in
                guard let self else { return }
                guard let data = try? JSONDecoder().decode(SyncMessage.self, from: data) else { return }
                switch data {
                    case .hash(let hashes):
                        sendComparingResult(with: hashes, to: peerID.id)
                    case .hashMatch(let result):
                        synchronize(with: result, to: peerID.id)
                        checkIfAllSynced()
                    case .request(let fileNames):
                        sendFiles(fileNames: fileNames, to: peerID.id, isRequested: true)
                    case .requestCompletionFlag:
                        receiveSyncFlags[peerID.id]  = true
                        checkIfAllSynced()
                    case .completed:
                        isSynchronized.send(())
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Public Methods
public extension SharingVideoRepository {
    func shareVideo(url: URL, resourceName: String) {
        socketProvider.broadcastResource(url: url, resourceName: resourceName)
    }
    
    func broadcastHashes() {
        guard !socketProvider.connectedPeers().isEmpty else { return isSynchronized.send(()) }
        
        let collectedHashes = synchronizer.collectHashes()
        let hashMessage = SyncMessage.hash(collectedHashes)
        
        guard let encodedData = try? JSONEncoder().encode(hashMessage) else { return }
        socketProvider.broadcast(data: encodedData)
        
        socketProvider.connectedPeers()
            .map { $0.id }
            .forEach {
                sendSyncFlags[$0] = false
                receiveSyncFlags[$0] = false
            }
        
        hasMismatch = false
    }
    
    func authorInformation() -> String {
        socketProvider.displayName
    }
}

// MARK: - Private Sync Methods
private extension SharingVideoRepository {
    func broadcastCompleted() {
        guard let completedMessage = try? JSONEncoder().encode(SyncMessage.completed) else { return }
        socketProvider.broadcast(data: completedMessage)
        isSynchronized.send(())
    }
    
    func sendComparingResult(with hashes: [String: String], to peerID: String) {
        let result = synchronizer.compareToLocal(with: hashes)
        let hashMessage = SyncMessage.hashMatch(result)
        
        guard let serializedData = try? JSONEncoder().encode(hashMessage) else { return }
        socketProvider.unicast(data: serializedData, to: peerID)
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
}
// MARK: - Private Methods
private extension SharingVideoRepository {
    func sendFiles(fileNames: [String], to peerID: String, isRequested: Bool) {
        guard !fileNames.isEmpty else {
            sendSyncFlags[peerID] = true
            return
        }
        
        for index in fileNames.indices {
            let fileName = fileNames[index]
            let fileURL = FileSystemManager.shared.folder.appending(component: fileName)

            socketProvider.unicastResource(
                url: fileURL,
                resourceName: fileName,
                to: peerID
            )
            sendSyncFlags[peerID] = true
        }
        
        if isRequested {
            sendRequestResponse(to: peerID)
        }
    }
    
    func requestFiles(fileNames: [String], to peerID: String) {
        guard !fileNames.isEmpty else {
            receiveSyncFlags[peerID] = true
            return
        }
        
        let request = SyncMessage.request(fileNames)
        guard let requestData = try? JSONEncoder().encode(request) else { return }
        socketProvider.unicast(data: requestData, to: peerID)
    }
    
    func sendRequestResponse(to peerID: String) {
        let receivedFlag = SyncMessage.requestCompletionFlag
        guard let data = try? JSONEncoder().encode(receivedFlag) else { return }
        self.socketProvider.unicast(data: data, to: peerID)
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

extension SharingVideoRepository {
    enum SyncMessage: Codable {
        case hash([String: String])
        case hashMatch([String: HashCondition])
        case request([String])
        case requestCompletionFlag
        case completed
    }
}
