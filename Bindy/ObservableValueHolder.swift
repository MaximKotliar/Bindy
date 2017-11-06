//
//  ObservableValueHolder.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/6/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

protocol ObservableValueHolder: ObserveCapable {
    
    var value: ObservableType { get }
    func transform(_ value: ObservableType) -> ChangeType
}

extension ObservableValueHolder {

    func transform(_ value: ObservableType) -> ChangeType {
        guard let value = value as? ChangeType else {
            let fromType = String(describing: ObservableType.self)
            let toType = String(describing: ChangeType.self)
            fatalError("Can't cast \(fromType) to \(toType), you should provide custom transform by overriding func transform(_ value: ObservableType) function.")
        }
        return value
    }

    @discardableResult
    func observe(_ owner: AnyObject,
                 callback: @escaping (ChangeType) -> Void) -> Self {
        callback(transform(value))
        return bind(owner, callback: callback)
    }
}
