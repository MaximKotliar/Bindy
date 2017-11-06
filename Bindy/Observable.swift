//
//  Observable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public final class Observable<T: Equatable>: ObservableValueHolder {

    public typealias ObservableType = T
    public typealias ChangeType = T

    var bindings = NSMapTable<AnyObject, Binding>.weakToStrongObjects()
    
    public var value: T {
        didSet {
            guard oldValue != self.value else { return }
            fireBindings(with: value)
        }
    }

    public init(_ value: T) {
        self.value = value
    }
}

extension Observable: Equatable {
    public static func == (lhs: Observable, rhs: Observable) -> Bool {
        return lhs === rhs
    }
}
