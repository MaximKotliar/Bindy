//
//  ObserveCapable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/6/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class BindingsContainer<T> {
    var actions: [(T) -> Void] = []
}

public class ObserveCapable<ObservableType> {

    typealias Binding = BindingsContainer<ObservableType>

    internal var bindings = NSMapTable<AnyObject, Binding>.weakToStrongObjects()

    @discardableResult
    public func bind(_ owner: AnyObject,
                     callback: @escaping (ObservableType) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Binding()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }

    @discardableResult
    public func unbind(_ owner: AnyObject) -> Bool {
        let hasBinding = bindings.object(forKey: owner) != nil
        bindings.removeObject(forKey: owner)
        return hasBinding
    }

    func fireBindings(with change: ObservableType) {
        guard let enumerator = self.bindings.objectEnumerator() else { return }
        enumerator.allObjects.forEach { bind in
            guard let bind = bind as? Binding else { return }
            bind.actions.forEach { $0(change) }
        }
    }

    public init() {}
}

extension ObserveCapable: Equatable {
    public static func == (lhs: ObserveCapable<ObservableType>,
                           rhs: ObserveCapable<ObservableType>) -> Bool {
        return lhs === rhs
    }
}
