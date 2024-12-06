//
//  PreviewContainer.swift
//  Feature
//
//  Created by jung on 12/6/24.
//

import Core
import Interfaces

public protocol PreviewDependency {
    var editVideoUseCase: EditVideoUseCaseInterface { get }
}

public protocol PreviewContainable {
    func coordinator(listener: PreviewListener) -> Coordinatable
}

public final class PreviewContainer:
    Container<PreviewDependency>, PreviewContainable {
    public func coordinator(listener: PreviewListener) -> Coordinatable {
        let viewModel = PreviewViewModel(usecase: dependency.editVideoUseCase)
        
        let coordinator = PreviewCoordinator(viewModel: viewModel)
        
        coordinator.listener = listener
        
        return coordinator
    }
}
