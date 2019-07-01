//
//  DSL.swift
//  Bindy
//
//  Created by Maxim Kotliar on 4/26/18.
//  Copyright © 2018 Maxim Kotliar. All rights reserved.
//

import Foundation

public extension Observable where T == Bool {

    static func && (lhs: Observable<T>, rhs: Observable<T>) -> Observable<T> {
        return lhs.combined(with: rhs, transform: { $0 && $1 })
    }

    static func || (lhs: Observable<T>, rhs: Observable<T>) -> Observable<T> {
        return lhs.combined(with: rhs, transform: { $0 || $1 })
    }
}
