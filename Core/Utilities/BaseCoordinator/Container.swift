//
//  Container.swift
//  Core
//
//  Created by jung on 12/6/24.
//

/// `Coordinator`, `ViewController`, `Interactor`에서 필요한 의존성을 들고 있으며, `Coordinator`생성을 담당하는 객체입니다.
open class Container<DependencyType> {
    public let dependency: DependencyType
    
    public init(dependency: DependencyType) {
        self.dependency = dependency
    }
}
