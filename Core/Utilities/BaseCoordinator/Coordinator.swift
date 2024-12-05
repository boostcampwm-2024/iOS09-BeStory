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
public protocol Coordinating: AnyObject {
    var navigationController: UINavigationController { get }
    var children: [Coordinating] { get }
    
    func start()
    func stop()
    func addChild(_ coordinator: Coordinating)
    func removeChild(_ coordinator: Coordinating)
}

public class Coordinator: Coordinating {
    public let navigationController: UINavigationController
    final public private(set)var children: [Coordinating] = []
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// 부모에게 붙여졌을 때, 원하는 동작을 해당 메서드에 구현합니다.
    public func start() { }
    
    /// 부모에게 제거되었을 때 원하는 동작을 해당 메서드에 구현합니다.
    public func stop() {
        self.removeAllChild()
    }
    
    public final func addChild(_ coordinator: Coordinating) {
        guard !children.contains(where: { $0 === coordinator }) else { return }
        
        children.append(coordinator)
        start()
    }
    
    public final func removeChild(_ coordinator: Coordinating) {
        guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
        
        children.remove(at: index)
        
        coordinator.stop()
    }
}

// MARK: - Private Methods
private extension Coordinator {
    func removeAllChild() {
        children.forEach { removeChild($0) }
    }
}
