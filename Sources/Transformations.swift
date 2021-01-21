//
//  Transformations.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/2/18.
//  Copyright © 2018 Maxim Kotliar. All rights reserved.
//

import Foundation

public extension Observable {
    
    func debounced(_ delay: TimeInterval, queue: DispatchQueue = .main, edge: DebounceEdge = .trailing) -> Observable<T> {
        let debounced = Observable<T>(value, options: options)
        var debounceFunc: ((T) -> Void)?
        bind(debounced) { [weak debounced] value in
            guard let debounced = debounced else { return }
            if debounceFunc == nil {
                debounceFunc = debounce(delay: delay, edge: edge, queue: queue) {
                    debounced.value = $0
                }
            }
            debounceFunc?(value)
        }
        return debounced
    }
    
    func throttled(_ delay: TimeInterval, queue: DispatchQueue = .main) -> Observable<T> {
        let throttled = Observable<T>(value, options: options)
        var throttledFunc: ((T) -> Void)?
        bind(throttled) { [weak throttled] value in
            guard let throttled = throttled else { return }
            if throttledFunc == nil {
                throttledFunc = throttle(delay: delay, queue: queue) {
                    throttled.value = $0
                }
            }
            throttledFunc?(value)
        }
        return throttled
    }
}

public extension Signal {
    
    func debounced(_ delay: TimeInterval, queue: DispatchQueue = .main, edge: DebounceEdge = .trailing) -> Signal<T> {
        let debounced = Signal<T>()
        var debounceFunc: ((T) -> Void)?
        bind(debounced) { [weak debounced] value in
            guard let debounced = debounced else { return }
            if debounceFunc == nil {
                debounceFunc = debounce(delay: delay, edge: edge, queue: queue) {
                    debounced.send($0)
                }
            }
            debounceFunc?(value)
        }
        return debounced
    }
    
    func throttled(_ delay: TimeInterval, queue: DispatchQueue) -> Signal<T> {
        let throttled = Signal<T>()
        var throttledFunc: ((T) -> Void)?
        bind(throttled) { [weak throttled] value in
            guard let throttled = throttled else { return }
            if throttledFunc == nil {
                throttledFunc = throttle(delay: delay, queue: queue) {
                    throttled.send($0)
                }
            }
            throttledFunc?(value)
        }
        return throttled
    }
}

public enum DebounceEdge {
    case leading
    case trailing
}

private func debounce<T>(delay: TimeInterval, edge: DebounceEdge, queue: DispatchQueue, action: @escaping ((T) -> Void)) -> (T) -> Void {
    switch edge {
    case .leading:
        var isLocked = false
        return { (p: T) in
            guard !isLocked else { return }
            isLocked = true
            queue.syncIfCurrentElseAsync { action(p) }
            queue.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) { isLocked = false }
        }
    case .trailing:
        var currentWorkItem: DispatchWorkItem?
        return { (p: T) in
            currentWorkItem?.cancel()
            currentWorkItem = DispatchWorkItem { action(p) }
            queue.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000)), execute: currentWorkItem!)
        }
    }
}

private func throttle<T>(delay: TimeInterval, queue: DispatchQueue, action: @escaping ((T) -> Void)) -> (T) -> Void {
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
        isPassed ? queue.async(execute: currentWorkItem!) : queue.asyncAfter(deadline: .now() + delay,
                                                                             execute: currentWorkItem!)
    }
}
