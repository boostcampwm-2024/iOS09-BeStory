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
    private let crdt: LWWElementSet<EditVideoElement>
    
    public let updatedVideos = PassthroughSubject<[Video], Never>()
    
    // MARK: - Initalizers
    public init(socketProvider: EditVideoSocketProvidable) {
        self.socketProvider = socketProvider
        let peerCount = socketProvider.connectedPeers().count
        self.crdt = LWWElementSet(id: UUID().uuidString, peerCount: peerCount)
    }
}

// MARK: - Public Methods
public extension EditVideoRepository {
    func trimmingVideo(_ video: Video) {
        Task {
            await editVideo(video)
        }
    }
    
    func reArrangingVideo(_ videos: [Video]) {
        Task {
            for video in videos {
                await editVideo(video)
            }
        }
    }
}

// MARK: - Private Methods
private extension EditVideoRepository {
    func binding() {
        socketProvider.dataShared
            .sink(with: self) { owner, data in
                owner.merge(data: data.0, from: data.1)
            }
            .store(in: &cancellables)
        
        Task {
            await crdt.updatedElements
                .sink(with: self) { owner, elements in
                    owner.sendVideo(elements: elements)
                }
                .store(in: &cancellables)
        }
    }
    
    func editVideo(_ video: Video) async {
        let element = DataMapper.mappingToEditVideoElement(
            video,
            editor: socketProvider.displayName
        )
        let elementSet = await crdt.localAdd(element: element)
        
        guard let elementData = try? JSONEncoder().encode(elementSet) else { return }
        
        socketProvider.broadcast(data: elementData)
    }
    
    // socket을 통해 데이터가 들어온 경우, crdt를 통해 merge
    func merge(data: Data, from user: SocketPeer) {
        guard
            let elementSet = try? JSONDecoder().decode(LWWElementSetState<EditVideoElement>.self, from: data)
        else { return }
        
        Task {
            await crdt.merge(with: elementSet)
        }
    }
    
    // crdt에서 업데이트가 온 경우, editingType에 따라 매핑하여 방출
    func sendVideo(elements: [EditVideoElement]) {        
        let videos = elements.map { DataMapper.mappingToVideo($0) }
        
        if !videos.isEmpty { updatedVideos.send(videos) }
    }
}
