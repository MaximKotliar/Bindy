//
//  ObservableArray.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

extension Array {

    subscript (safe index: Int) -> Element? {
        guard index < self.count else { return nil }
        return self[index]
    }
}

extension Range {

    @discardableResult
    public func intersect(_ other: Range) -> Range {
        guard upperBound > other.lowerBound else {
            return upperBound..<upperBound
        }
        guard other.upperBound > lowerBound else {
            return lowerBound..<lowerBound
        }
        let lower = other.lowerBound > upperBound ? other.lowerBound : lowerBound
        let upper = other.upperBound < upperBound ? other.upperBound : upperBound
        return lower..<upper
    }
}

public final class ObservableArray<T: Equatable>: ObservableValueHolder<[T]>, Collection, MutableCollection, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByArrayLiteral, RangeReplaceableCollection {

    public typealias Element = T

    public struct Update {
        public enum Event {
            case insert
            case delete
            case replace
        }

        public let event: Event
        public let indexes: [Index]

        public init(_ type: Event,
                    _ indexes: [Index]) {
            self.event = type
            self.indexes = indexes
        }
    }

    public let updates = Signal<[Update]>()

    public init() {
        super.init([])
    }

    override public var value: [T] {
        didSet {
            guard oldValue != value else { return }
            fireBindings(with: value)
        }
    }
    
    public var startIndex: Int { return value.startIndex }
    
    public var endIndex: Int { return value.endIndex }
    
    public func index(after i: Int) -> Int { return value.index(after: i) }
    
    public func index(before i: Int) -> Int {
        return value.index(before: i)
    }
    
    public var description: String {
        return value.description
    }
    
    public var debugDescription: String {
        return value.debugDescription
    }
    
    public required init(arrayLiteral elements: T...) {
        super.init(elements)
    }

    // Subscripts
    public subscript(index: Int) -> T {
        get {
            return value[index]
        }
        set {
            value[index] = newValue
            if index == value.count {
                updates.send([Update(.insert, [index])])
            } else {
                updates.send([Update(.replace, [index])])
            }
        }
    }

    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            return value[bounds]
        }
        set {
            value[bounds] = newValue
            let first = bounds.lowerBound
            updates.send([Update(.insert, Array(first..<first + newValue.count)),
                          Update(.delete, Array(bounds.lowerBound..<bounds.upperBound))])
        }
    }

    // Insertions
    public func insert(_ newElement: T, at i: Index) {
        value.insert(newElement, at: i)
        updates.send([Update(.insert, [i])])
    }

    public func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, T == C.Element {
        guard !newElements.isEmpty else { return }
        let oldCount = value.count
        value.insert(contentsOf: newElements, at: i)
        let insertedCount = value.count - oldCount
        updates.send([Update(.insert, Array(i..<i + insertedCount))])
    }

    public func append(_ newElement: T) {
        value.append(newElement)
        updates.send([Update(.insert, [value.count - 1])])
    }

    public func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
        let end = value.count
        value.append(contentsOf: newElements)
        guard end != value.count else { return }
        updates.send([Update(.insert, Array(end..<value.count))])
    }

    // Deletions
    public func removeLast() -> Element {
        let element = value.removeLast()
        updates.send([Update(.delete, [value.count])])
        return element
    }

    @discardableResult
    public func remove(at position: Int) -> Element {
        let element = value.remove(at: position)
        updates.send([Update(.delete, [position])])
        return element
    }

    public func removeAll(keepingCapacity keepCapacity: Bool) {
        guard !value.isEmpty else { return }
        let oldCount = value.count
        value.removeAll(keepingCapacity: keepCapacity)
        updates.send([Update(.delete, Array(0..<oldCount))])
    }

    // Subrange replacements
    public func replaceSubrange<C>(_ subrange: Range<Index>,
                                   with newElements: C) where C: Collection,
        C.Iterator.Element == T {

            let oldCount = value.count
            value.replaceSubrange(subrange, with: newElements)
            let first = subrange.lowerBound
            let newCount = value.count
            let end = first + (newCount - oldCount) + subrange.count
            updates.send([Update(.insert, Array(first..<end)),
                          Update(.delete, Array(subrange.lowerBound..<subrange.upperBound))])
    }

    public func replaceAll(with new: [T]) {
        let old = value
        let maxCount = Swift.max(old.count, new.count)

        var replacements: [Index] = []
        var insertions: [Index] = []
        var deletions: [Index] = []
        for index in 0...maxCount {
            let left = old[safe: index]
            let right = new[safe: index]
            switch (left, right) {
            case (.some(let l), .some(let r)):
                guard l != r else { continue }
                replacements.append(index)
            case (.none, .some):
                insertions.append(index)
            case (.some, .none):
                deletions.append(index)
            case (.none, .none):
                break
            }
        }

        var updates: [Update] = []
        if !replacements.isEmpty {
            updates.append(Update(.replace, replacements))
        }
        if !insertions.isEmpty {
            updates.append(Update(.insert, insertions))
        }
        if !deletions.isEmpty {
            updates.append(Update(.delete, deletions))
        }

        value = new

        if !updates.isEmpty {
            self.updates.send(updates)
        }
    }
}
