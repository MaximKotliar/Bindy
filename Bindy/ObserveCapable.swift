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

protocol ObserveCapable {

    associatedtype ObservableType
    associatedtype ChangeType

    typealias Binding = BindingsContainer<ChangeType>

    var bindings: NSMapTable<AnyObject, Binding> { get }

    @discardableResult
    func bind(_ owner: AnyObject, callback: @escaping (ChangeType) -> Void) -> Self

    @discardableResult
    func unbind(_ owner: AnyObject) -> Bool
}

extension ObserveCapable {

    internal func fireBindings(with change: ChangeType) {
        guard let enumerator = self.bindings.objectEnumerator() else { return }
        enumerator.allObjects.forEach { bind in
            guard let bind = bind as? Binding else { return }
            bind.actions.forEach { $0(change) }
        }
    }

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
}
