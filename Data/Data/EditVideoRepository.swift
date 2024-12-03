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
    
    public let trimmingVideo = PassthroughSubject<[Video], Never>()
    public let reArrangingVideo = PassthroughSubject<[Video], Never>()
    
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
            await editVideo(video, editingType: .trimming)
        }
    }
    
    func reArrangingVideo(_ video: Video) {
        Task {
            await editVideo(video, editingType: .rearraring)
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
    
    func editVideo(_ video: Video, editingType: EditingType) async {
        let element = DataMapper.mappingToEditVideoElement(
            video,
            editor: socketProvider.displayName,
            editingType: editingType
        )
        let elementSet = await crdt.localAdd(element: element)
        await crdt.merge(with: elementSet)
        
        guard let elementData = try? JSONEncoder().encode(elementSet) else { return }
        
        socketProvider.broadcast(data: elementData)
    }
    
    // socket을 통해 데이터가 들어온 경우, crdt를 통해 merge
    func merge(data: Data, from user: SocketPeer) {
        guard
            let dto = try? JSONDecoder().decode(EditVideoDTO.self, from: data),
            let element = DataMapper.mappingToEditVideoElement(dto, from: user)
        else { return }
        
        Task {
            let elementSet = await crdt.localAdd(element: element)
            await crdt.merge(with: elementSet)
        }
    }
    
    // crdt에서 업데이트가 온 경우, editingType에 따라 매핑하여 방출
    func sendVideo(elements: [EditVideoElement]) {
        var trimmingVidoes: [Video] = []
        var reArrangingVideos: [Video] = []
        
        elements.forEach {
            let video = DataMapper.mappingToVideo($0)
            
            switch $0.editingType {
                case .trimming:
                    trimmingVidoes.append(video)
                case .rearraring:
                    reArrangingVideos.append(video)
            }
        }
        
        if !trimmingVidoes.isEmpty { trimmingVideo.send(trimmingVidoes) }
        if !reArrangingVideos.isEmpty { reArrangingVideo.send(reArrangingVideos) }
    }
}
