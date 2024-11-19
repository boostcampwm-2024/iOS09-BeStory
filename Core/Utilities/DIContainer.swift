//
//  DIContainer.swift
//  Core
//
//  Created by 이숲 on 11/20/24.
//

public final class DIContainer {
    public static let shared = DIContainer()

    private var services: [String: Any] = [:]

    public func register<T>(type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }

    public func resolve<T>(type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("\(key) is not registered.")
        }
        return service
    }
}
