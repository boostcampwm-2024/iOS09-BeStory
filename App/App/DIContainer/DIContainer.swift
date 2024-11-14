//
//  DIContainer.swift
//  App
//
//  Created by 이숲 on 11/14/24.
//

final class DIContainer {
    private var services: [String: Any] = [:]

    func register<T>(type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }

    func resolve<T>(type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("\(key) is not registered.")
        }
        return service
    }
}
