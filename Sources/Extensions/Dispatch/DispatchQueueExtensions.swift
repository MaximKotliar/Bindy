//
//  DispatchQueueExtensions.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11.03.2020.
//  Copyright © 2020 Maxim Kotliar. All rights reserved.
//

import Dispatch

// MARK: - Properties
extension DispatchQueue {

    static var isMainQueue: Bool {
        enum Static {
            static var key: DispatchSpecificKey<Void> = {
                let key = DispatchSpecificKey<Void>()
                DispatchQueue.main.setSpecific(key: key, value: ())
                return key
            }()
        }
        return DispatchQueue.getSpecific(key: Static.key) != nil
    }
}

extension DispatchQueue {
    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<Void>()

        queue.setSpecific(key: key, value: ())
        defer { queue.setSpecific(key: key, value: nil) }

        return DispatchQueue.getSpecific(key: key) != nil
    }
}

extension DispatchQueue {

    func syncIfCurrentElseAsync(execute actions: @escaping () -> Void) {
        if DispatchQueue.isCurrent(self) {
            actions()
        } else {
            async(execute: actions)
        }
    }
}
