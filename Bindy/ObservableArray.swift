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

public class ObservableArray<T: Equatable>: Collection, MutableCollection, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByArrayLiteral, RangeReplaceableCollection, Equatable {

    public typealias Callback = (Change<[T]>) -> Void
    public typealias Element = T
    
    class Bind {
        var actions: [Callback] = []
    }

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
    
    public required init() {
        array = []
    }
    
    public init(array: [Element]) {
        self.array = array
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()

    internal var array: [T] {
        didSet {
            guard oldValue != array,
                let enumerator = bindings.objectEnumerator() else { return }
            let change = Change(oldValue: oldValue,
                                newValue: array)
            enumerator.allObjects.forEach { bind in
                (bind as? Bind)?.actions.forEach { $0(change) }
            }
        }
    }
    
    @discardableResult
    public func observe(_ owner: AnyObject, callback: @escaping Callback) -> Self {
        let change = Change(oldValue: [],
                            newValue: array)
        callback(change)
        return bind(owner, callback: callback)
    }
    
    @discardableResult
    public func bind(_ owner: AnyObject, callback: @escaping Callback) -> Self {
        let bind = bindings.object(forKey: owner) ?? Bind()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }
    
    public func unbind(_ owner: AnyObject) {
        bindings.removeObject(forKey: owner)
    }
    
    public var startIndex: Int { return array.startIndex }
    
    public var endIndex: Int { return array.endIndex }
    
    public func index(after i: Int) -> Int { return array.index(after: i) }
    
    public func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    
    public var description: String {
        return array.description
    }
    
    public var debugDescription: String {
        return array.debugDescription
    }
    
    public required init(arrayLiteral elements: T...) {
        array = Array(elements)
    }

    // Subscripts
    public subscript(index: Int) -> T {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
            if index == array.count {
                updates.send([Update(.insert, [index])])
            } else {
                updates.send([Update(.replace, [index])])
            }
        }
    }

    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            return array[bounds]
        }
        set {
            array[bounds] = newValue
            let first = bounds.lowerBound
            updates.send([Update(.insert, Array(first..<first + newValue.count)),
                          Update(.delete, Array(bounds.lowerBound..<bounds.upperBound))])
        }
    }

    // Insertions
    public func insert(_ newElement: T, at i: Index) {
        array.insert(newElement, at: i)
        updates.send([Update(.insert, [i])])
    }

    public func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, T == C.Element {
        guard !newElements.isEmpty else { return }
        let oldCount = array.count
        array.insert(contentsOf: newElements, at: i)
        let insertedCount = array.count - oldCount
        updates.send([Update(.insert, Array(i..<i + insertedCount))])
    }

    public func append(_ newElement: T) {
        array.append(newElement)
        updates.send([Update(.insert, [array.count - 1])])
    }

    public func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
        let end = array.count
        array.append(contentsOf: newElements)
        guard end != array.count else { return }
        updates.send([Update(.insert, Array(end..<array.count))])
    }

    // Deletions
    public func removeLast() -> Element {
        let element = array.removeLast()
        updates.send([Update(.delete, [array.count])])
        return element
    }

    @discardableResult
    public func remove(at position: Int) -> Element {
        let element = array.remove(at: position)
        updates.send([Update(.delete, [position])])
        return element
    }

    public func removeAll(keepingCapacity keepCapacity: Bool) {
        guard !array.isEmpty else { return }
        let oldCount = array.count
        array.removeAll(keepingCapacity: keepCapacity)
        updates.send([Update(.delete, Array(0..<oldCount))])
    }

    // Subrange replacements
    public func replaceSubrange<C>(_ subrange: Range<Index>,
                                   with newElements: C) where C: Collection,
        C.Iterator.Element == T {

            let oldCount = array.count
            array.replaceSubrange(subrange, with: newElements)
            let first = subrange.lowerBound
            let newCount = array.count
            let end = first + (newCount - oldCount) + subrange.count
            updates.send([Update(.insert, Array(first..<end)),
                          Update(.delete, Array(subrange.lowerBound..<subrange.upperBound))])
    }

    public func replaceAll(with new: [T]) {
        let old = array
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

        array = new

        if !updates.isEmpty {
            self.updates.send(updates)
        }
    }

    public static func == (lhs: ObservableArray<T>,
                           rhs: ObservableArray<T>) -> Bool {
        return lhs.array == rhs.array
    }
}
