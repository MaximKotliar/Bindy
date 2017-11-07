//
//  ObservableValueHolder.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/6/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class ObservableValueHolder<ObservableType, ChangeType>: ObserveCapable<ObservableType, ChangeType> {

    open var value: ObservableType

    open func transform(_ value: ObservableType) -> ChangeType {
        guard let value = value as? ChangeType else {
            let fromType = String(describing: ObservableType.self)
            let toType = String(describing: ChangeType.self)
            fatalError("Can't cast \(fromType) to \(toType), you should provide custom transform by overriding func transform(_ value: ObservableType) function.")
        }
        return value
    }

    @discardableResult
    public func observe(_ owner: AnyObject,
                        callback: @escaping (ChangeType) -> Void) -> Self {
        callback(transform(value))
        return bind(owner, callback: callback)
    }

    public init(_ value: ObservableType) {
        self.value = value
    }
}
