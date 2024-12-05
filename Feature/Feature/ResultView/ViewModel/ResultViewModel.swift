//
//  ResultViewModel.swift
//  Feature
//
//  Created by 디해 on 12/5/24.
//

import Combine
import Foundation
import Interfaces

public final class ResultViewModel {
    typealias Input = ResultViewInput
    typealias Output = ResultViewOutput
    
    var output = PassthroughSubject<Output, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    private let usecase: EditVideoUseCaseInterface
    
    public init(usecase: EditVideoUseCaseInterface) {
        self.usecase = usecase
        setupBind()
    }
    
    func transform(input: AnyPublisher<ResultViewInput, Never>) -> AnyPublisher<ResultViewOutput, Never> {
        input.sink(with: self) { owner, input in
            switch input {
            
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}
