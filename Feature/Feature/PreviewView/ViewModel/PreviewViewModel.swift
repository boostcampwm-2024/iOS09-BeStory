//
//  ResultViewModel.swift
//  Feature
//
//  Created by 디해 on 12/5/24.
//

import Combine
import Core
import Foundation
import Photos
import Interfaces

protocol PreviewCoordinatable: AnyObject { }

public final class PreviewViewModel {
    typealias Input = PreviewViewInput
    typealias Output = PreviewViewOutput
    
    weak var coordinator: PreviewCoordinatable?
    var output = PassthroughSubject<Output, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    private let usecase: EditVideoUseCaseInterface
    
    public init(usecase: EditVideoUseCaseInterface) {
        self.usecase = usecase
    }
    
    func transform(_ input: AnyPublisher<PreviewViewInput, Never>) -> AnyPublisher<PreviewViewOutput, Never> {
        input.sink(with: self) { owner, input in
            switch input {
            case .loadPreview(let size):
                Task {
                    let videos = owner.usecase.videos
                    guard let preview = try? await VideoMerger.preview(videos: videos, size: size) else { return }
                    owner.output.send(.loadedPreview(playerItem: preview))
                }
                
            case .saveVideo:
                Task { @MainActor in
                    let outputURL = FileSystemManager.shared.folder
                        .appending(path: UUID().uuidString)
                        .appendingPathExtension("mp4")
                    let videos = owner.usecase.videos
                    try? await VideoMerger.mergeWithSave(videos, outputURL: outputURL)
                    
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized else { return }
                    }
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                    }) { success, _ in
                        if success {
                            owner.output.send(.videoSaved)
                        }
                    }
                }
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}
