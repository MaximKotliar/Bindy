//
//  KVOSupport.swift
//  Bindy
//
//  Created by Maxim Kotliar on 2/22/19.
//  Copyright © 2019 Maxim Kotliar. All rights reserved.
//

import Foundation

public protocol KVOObservable where Self: NSObject {}

extension NSObject: KVOObservable {}

public extension KVOObservable {

    func observable<Value>(for keyPath: KeyPath<Self, Value>) -> Observable<Value> {
        let initial = self[keyPath: keyPath]
        let observable = Observable(initial)
        let kvoToken = self.observe(keyPath, options: [.new]) { [unowned observable] _, change in
            guard let new = change.newValue else { return }
            observable.value = new
        }
        // Empty binding for retain kvoToken
        observable.bind(observable) { _ in
            let _ = kvoToken
        }
        return observable
    }

    subscript <Value>(_ keyPath: KeyPath<Self, Value>) -> Observable<Value> {
        return observable(for: keyPath)
    }
}
