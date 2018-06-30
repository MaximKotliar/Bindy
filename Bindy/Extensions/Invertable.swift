//
//  Invertable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 1/10/18.
//  Copyright © 2018 Maxim Kotliar. All rights reserved.
//

import Foundation

public protocol Invertable {
    var inverted: Self { get }
}

extension Invertable {
    public mutating func invert() {
        self = inverted
    }

    static prefix public func ! (rhs: Self) -> Self {
        return rhs.inverted
    }
}

extension Bool: Invertable {
    public var inverted: Bool { return !self }
}

extension Observable: Invertable where T: Invertable {
    public var inverted: Observable<T> {
        return transform { $0.inverted }
    }
}
