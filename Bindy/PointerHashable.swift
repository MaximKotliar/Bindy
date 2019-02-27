//
//  PointerHashable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 2/27/19.
//  Copyright © 2019 Maxim Kotliar. All rights reserved.
//

import Foundation

protocol CustomPointerHashable: class, Hashable {
    var pointerHashableObject: AnyObject { get }
}

extension CustomPointerHashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.pointerHashableObject === rhs.pointerHashableObject
    }

    var hashValue: Int {
        return ObjectIdentifier(pointerHashableObject).hashValue
    }
}

protocol PointerHashable: CustomPointerHashable {}

extension PointerHashable {
    var pointerHashableObject: AnyObject {
        return self
    }
}
