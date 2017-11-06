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

public class ObserveCapable<ObservableType, ChangeType> {

    typealias Binding = BindingsContainer<ChangeType>

    internal var bindings = NSMapTable<AnyObject, Binding>.weakToStrongObjects()

    @discardableResult
    public func bind(_ owner: AnyObject,
                     callback: @escaping (ChangeType) -> Void) -> Self {
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

    func fireBindings(with change: ChangeType) {
        guard let enumerator = self.bindings.objectEnumerator() else { return }
        enumerator.allObjects.forEach { bind in
            guard let bind = bind as? Binding else { return }
            bind.actions.forEach { $0(change) }
        }
    }

    init() {}
}

extension ObserveCapable: Equatable {
    public static func == (lhs: ObserveCapable<ObservableType, ChangeType>,
                           rhs: ObserveCapable<ObservableType, ChangeType>) -> Bool {
        return lhs === rhs
    }
}
