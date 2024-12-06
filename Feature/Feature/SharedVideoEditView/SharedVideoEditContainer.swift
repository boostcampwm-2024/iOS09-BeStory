//
//  SharedEditVideoContainer.swift
//  Feature
//
//  Created by jung on 12/6/24.
//

import Core
import Interfaces

public protocol SharedEditVideoDependency {
    var editVideoUseCase: EditVideoUseCaseInterface { get }
    var previewContainer: PreviewContainable { get }
}

public protocol SharedEditVideoContainable {
    func coordinator(listener: SharedVideoEditListener) -> Coordinatable
}

public final class SharedVideoEditContainer:
    Container<SharedEditVideoDependency>, SharedEditVideoContainable {
    public func coordinator(listener: SharedVideoEditListener) -> Coordinatable {
        let viewModel = SharedVideoEditViewModel(usecase: dependency.editVideoUseCase)
        
        let coordinator = SharedVideoEditCoordinator(
            viewModel: viewModel,
            previewContainer: dependency.previewContainer
        )
        
        coordinator.listener = listener
        
        return coordinator
    }
}
