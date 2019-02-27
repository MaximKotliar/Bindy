//
//  GlobalStorage.swift
//  Bindy
//
//  Created by Maxim Kotliar on 2/27/19.
//  Copyright © 2019 Maxim Kotliar. All rights reserved.
//

import Foundation

class AnyObjectWrapper {
    static var storage: Set<AnyObjectWrapper> = []

    let object: AnyObject
    var releaseClosure: (() -> Void)!

    init(_ object: AnyObject) {
        self.object = object
        releaseClosure = { [unowned self] in
            AnyObjectWrapper.storage.remove(self)
        }
    }
}

extension AnyObjectWrapper: CustomPointerHashable {
    var pointerHashableObject: AnyObject {
        return object
    }
}
