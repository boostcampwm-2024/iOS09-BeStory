//
//  EditVideoRepository.swift
//  Data
//
//  Created by jung on 12/3/24.
//

import Core
import Combine
import CRDT
import Entity
import Foundation
import Interfaces
import P2PSocket

public final class EditVideoRepository: EditVideoRepositoryInterface {
    public typealias EditVideoSocketProvidable = SocketDataSendable & SocketBrowsable
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private let socketProvider: EditVideoSocketProvidable
    private var elementSet: LWWElementSet<EditVideoElement>
    
    public let editedVideos = PassthroughSubject<[Video], Never>()
    
    // MARK: - Initalizers
    public init(socketProvider: EditVideoSocketProvidable) {
        self.socketProvider = socketProvider
        let id = socketProvider.id
        let peerIDs = socketProvider.connectedPeers().map { $0.id }
        self.elementSet = .init(id: id, peerIDs: peerIDs)
        
        binding()
    }
}

// MARK: - Public Methods
public extension EditVideoRepository {
    func trimmingVideo(_ video: Video) {
        Task {
            let elementSetState = await elementSetState(video)
            
            guard let elementData = try? JSONEncoder().encode(elementSetState) else { return }
            
            socketProvider.broadcast(data: elementData)
        }
    }
    
    func reArrangingVideo(_ videos: [Video]) {
        Task {
            let elementSetState = await elementSetState(videos)
            
            guard let elementData = try? JSONEncoder().encode(elementSetState) else { return }
            
            socketProvider.broadcast(data: elementData)
        }
    }
}

// MARK: - Binding
private extension EditVideoRepository {
    func binding() {
        socketProvider.dataShared
            .sink(with: self) { owner, data in
                owner.merge(data: data.0)
            }
            .store(in: &cancellables)
        
        Task {
            await elementSet.updatedElements
                .sink(with: self) { owner, elements in
                    owner.sendVideo(elements: elements)
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - Private Methods
private extension EditVideoRepository {
    @discardableResult
    func elementSetState(_ vidoes: [Video]) async -> LWWElementSetState<EditVideoElement> {
        let elements = vidoes.map {
            DataMapper.mappingToEditVideoElement(
                $0,
                editorID: socketProvider.id,
                editorName: socketProvider.displayName
            )
        }
        
        return await elementSet.localAdd(elements: elements)
    }
    
    @discardableResult
    func elementSetState(_ video: Video) async -> LWWElementSetState<EditVideoElement> {
        let element = DataMapper.mappingToEditVideoElement(
            video,
            editorID: socketProvider.id,
            editorName: socketProvider.displayName
        )
        
        return await elementSet.localAdd(element: element)
    }
    
    func merge(data: Data) {
        guard
            let elementSetState = try? JSONDecoder().decode(LWWElementSetState<EditVideoElement>.self, from: data)
        else { return }
        Task {
            await elementSet.merge(with: elementSetState)
        }
    }
    
    func sendVideo(elements: [EditVideoElement]) {
        let videos = elements.compactMap { DataMapper.mappingToVideo($0) }
        
        if !videos.isEmpty { editedVideos.send(videos) }
    }
}
