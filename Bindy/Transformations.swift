//
//  Transformations.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/2/18.
//  Copyright © 2018 Maxim Kotliar. All rights reserved.
//

import Foundation

public extension Observable {

    public func debounced(_ delay: TimeInterval) -> Observable<T> {
        let debounced = Observable<T>(value, options: ["c": comparsionClosure as Any])
        var debounceFunc: ((T) -> Void)?
        bind(debounced) { [weak debounced] value in
            guard let debounced = debounced else { return }
            if debounceFunc == nil {
                debounceFunc = debounce(delay: delay) {
                    debounced.value = $0
                }
            }
            debounceFunc?(value)
        }
        return debounced
    }

    public func throttled(_ delay: TimeInterval) -> Observable<T> {
        let throttled = Observable<T>(value, options: ["c": comparsionClosure as Any])
        var throttledFunc: ((T) -> Void)?
        bind(throttled) { [weak throttled] value in
            guard let throttled = throttled else { return }
            if throttledFunc == nil {
                throttledFunc = throttle(delay: delay) {
                    throttled.value = $0
                }
            }
            throttledFunc?(value)
        }
        return throttled
    }
}

public extension Signal {

    public func debounced(_ delay: TimeInterval) -> Signal<T> {
        let debounced = Signal<T>()
        var debounceFunc: ((T) -> Void)?
        bind(debounced) { [weak debounced] value in
            guard let debounced = debounced else { return }
            if debounceFunc == nil {
                debounceFunc = debounce(delay: delay) {
                    debounced.send($0)
                }
            }
            debounceFunc?(value)
        }
        return debounced
    }

    public func throttled(_ delay: TimeInterval) -> Signal<T> {
        let throttled = Signal<T>()
        var throttledFunc: ((T) -> Void)?
        bind(throttled) { [weak throttled] value in
            guard let throttled = throttled else { return }
            if throttledFunc == nil {
                throttledFunc = throttle(delay: delay) {
                    throttled.send($0)
                }
            }
            throttledFunc?(value)
        }
        return throttled
    }
}

private func debounce<T>(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping ((T) -> Void)) -> (T) -> Void {
    var currentWorkItem: DispatchWorkItem?
    return { (p: T) in
        currentWorkItem?.cancel()
        currentWorkItem = DispatchWorkItem { action(p) }
        queue.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000)), execute: currentWorkItem!)
    }
}

private func throttle<T>(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping ((T) -> Void)) -> (T) -> Void {
    var currentWorkItem: DispatchWorkItem?
    var lastFire: TimeInterval = 0
    return { (p: T) in
        guard currentWorkItem == nil else { return }
        currentWorkItem = DispatchWorkItem {
            action(p)
            lastFire = Date().timeIntervalSinceReferenceDate
            currentWorkItem = nil
        }
        let isPassed = Date().timeIntervalSinceReferenceDate - delay > lastFire
        isPassed ? queue.async(execute: currentWorkItem!) : queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
    }
}
