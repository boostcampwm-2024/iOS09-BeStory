//
//  Coordinator.swift
//  Core
//
//  Created by jung on 12/5/24.
//

import UIKit

/// 부모 Coordinator에게 요청하는 메서드를 구현하면 됩니다.
public protocol CoordinatorListener: AnyObject { }

/// 화면 전환 로직 및, `ViewController`와 `Interactor`생성을 담당하는 객체입니다.
public protocol Coordinatable: AnyObject {
    var navigationController: UINavigationController? { get set }
    var children: [Coordinatable] { get }

    func start(_ navigationController: UINavigationController?)
    func stop()
    func addChild(_ coordinator: Coordinatable)
    func removeChild(_ coordinator: Coordinatable)
}

open class Coordinator: Coordinatable {
    public var navigationController: UINavigationController?
    public final var children: [Coordinatable] = []

    public init() { }

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// 부모에게 붙여졌을 때, 원하는 동작을 해당 메서드에 구현합니다.
    open func start(_ navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    /// 부모에게 제거되었을 때 원하는 동작을 해당 메서드에 구현합니다.
    open func stop() {
        navigationController?.popViewController(animated: true)
        navigationController = nil
    }
    
    public final func addChild(_ coordinator: Coordinatable) {
        guard !children.contains(where: { $0 === coordinator }) else { return }
        
        children.append(coordinator)
    }
    
    public final func removeChild(_ coordinator: Coordinatable) {
        guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
        
        children.remove(at: index)
    }

    deinit {
        self.stop()
        if !children.isEmpty { removeAllChild() }
    }
}

// MARK: - Private Methods
private extension Coordinator {
    func removeAllChild() {
        children.forEach { removeChild($0) }
    }
}
