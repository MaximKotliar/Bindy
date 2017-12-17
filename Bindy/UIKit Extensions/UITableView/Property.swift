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

    func bind(to observable: Observable<Type>){
        observable.observe(parent) { value in
            self.update(value)
        }
    }

    // Syntax sugar
    func to(_ observable: Observable<Type>) {
        bind(to: observable)
    }
}
