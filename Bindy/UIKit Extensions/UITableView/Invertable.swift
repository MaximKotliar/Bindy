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

extension Bool: Invertable {

    public var inverted: Bool { return !self }
}
