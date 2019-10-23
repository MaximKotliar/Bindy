//
//  ObserveCapable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/6/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class BindingsContainer<T> {
    enum Change {
        case oldValue(T)
        case newValue(T)
        case oldValueNewValue(T, T)
    }

    var oldValueActions: [(T) -> Void] = []
    var newValueActions: [(T) -> Void] = []
    var oldValueNewValueActions: [(T, T) -> Void] = []
}

public class ObserveCapable<ObservableType> {

    typealias Binding = BindingsContainer<ObservableType>

    internal var bindings = NSMapTable<AnyObject, Binding>.weakToStrongObjects()

    public init() {}
}

public extension ObserveCapable {

    @discardableResult
    func bind(_ owner: AnyObject,
              callback: @escaping (ObservableType) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Binding()
        bind.newValueActions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }

    @discardableResult
    func unbind(_ owner: AnyObject) -> Bool {
        let hasBinding = bindings.object(forKey: owner) != nil
        bindings.removeObject(forKey: owner)
        return hasBinding
    }
}

internal extension ObserveCapable {
    func fireBindings(with change: BindingsContainer<ObservableType>.Change) {
        guard let enumerator = self.bindings.objectEnumerator() else { return }
        switch change {
        case .newValue(let new):
            enumerator.allObjects.forEach { bind in
                guard let bind = bind as? Binding else { return }
                bind.newValueActions.forEach { $0(new) }
            }
        case .oldValue(let old):
            enumerator.allObjects.forEach { bind in
                guard let bind = bind as? Binding else { return }
                bind.oldValueActions.forEach { $0(old) }
            }
        case .oldValueNewValue(let old, let new):
            enumerator.allObjects.forEach { bind in
                guard let bind = bind as? Binding else { return }
                bind.oldValueActions.forEach { $0(old) }
                bind.newValueActions.forEach { $0(new) }
                bind.oldValueNewValueActions.forEach { $0(old, new) }
            }
        }
    }
}

extension ObserveCapable: Equatable {
    public static func == (lhs: ObserveCapable<ObservableType>,
                           rhs: ObserveCapable<ObservableType>) -> Bool {
        return lhs === rhs
    }
}
