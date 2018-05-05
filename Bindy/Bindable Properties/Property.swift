//
//  Property.swift
//  Bindy
//
//  Created by Maxim Kotliar on 12/17/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public struct Property<Parent: AnyObject, Type: Equatable> {

    public let parent: Parent
    public let update: (Type) -> ()
}

extension Property {

    public func bind(to observable: Observable<Type>){
        observable.observe(parent) { value in
            self.update(value)
        }
    }

    // Syntax sugar
    public func to(_ observable: Observable<Type>) {
        bind(to: observable)
    }
}

extension Property where Type: Invertable {

    public func bind(to observable: Observable<Type>, inverted: Bool = false) {
        observable.observe(parent) { value in
            self.update(inverted ? !value : value)
        }
    }

    // Syntax sugar
    public func to(_ observable: Observable<Type>, inverted: Bool = false) {
        bind(to: observable, inverted: inverted)
    }
}
