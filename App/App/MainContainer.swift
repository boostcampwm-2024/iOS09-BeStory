//
//  MainContainer.swift
//  App
//
//  Created by jung on 12/6/24.
//

import Core
import Feature
import P2PSocket
import UseCase
import Data
import Interfaces

final class MainContainer:
    ConnectionDependency,
    VideoListDependency,
    GroupInfoDependency,
    SharedEditVideoDependency,
    PreviewDependency {
    let socketProvider = SocketProvider()
    
    func coordinator() -> Coordinator {
        let groupInfoContainer = GroupInfoContainer(dependency: self)
        let connectionContainer = ConnectionContainer(dependency: self)
        
        return MainCoordinator(
            groupInfoContainer: groupInfoContainer,
            connectionContainer: connectionContainer
        )
    }
    
    // MARK: - Containable
    var videoListContaiable: VideoListContainable {
        return VideoListContainer(dependency: self)
    }
    
    var sharedEditVideoContainer: SharedEditVideoContainable {
        return SharedVideoEditContainer(dependency: self)
    }
    
    var previewContainer: PreviewContainable {
        return PreviewContainer(dependency: self)
    }

    // MARK: - Repository
    var browsingUserRepository: BrowsingUserRepositoryInterface {
        return BrowsingUserRepository(socketProvider: socketProvider)
    }
    
    var connectedUserRepository: ConnectedUserRepositoryInterface {
        return ConnectedUserRepository(socketProvider: socketProvider)
    }
    
    var sharingVideoRepository: SharingVideoRepositoryInterface {
        return SharingVideoRepository(socketProvider: socketProvider)
    }
    
    var editVideoRepository: EditVideoRepositoryInterface {
        return EditVideoRepository(socketProvider: socketProvider)
    }
    
    // MARK: - UseCase
    var browsingUseCase: BrowsingUserUseCaseInterface {
        return BrowsingUserUseCase(repository: browsingUserRepository)
    }
    
    var connectedUserUseCase: ConnectedUserUseCaseInterface {
        return ConnectedUserUseCase(repository: connectedUserRepository)
    }
    
    lazy var videoUseCase: VideoUseCase = {
        return VideoUseCase(sharingVideoRepository: sharingVideoRepository, editVideoRepository: editVideoRepository)
    }()
    
    var sharingVideoUseCase: SharingVideoUseCaseInterface {
        videoUseCase
    }
    
    var editVideoUseCase: EditVideoUseCaseInterface {
        videoUseCase
    }
}
