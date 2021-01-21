//
//  TransformationsTests.swift
//  
//
//  Created by Alexander Karpov on 21.01.2021.
//

import XCTest
@testable import Bindy

final class TransformationsTests: XCTestCase {

    func testMap() {
        let observable = Observable<String>("test")
        let mapped = observable.map { $0.count }
        let asyncExpectation = expectation(description: "Expect to call")
        mapped.bind(self) { old, new in
            guard old == 4 else { return }
            guard new == 0 else { return }
            asyncExpectation.fulfill()
        }
        observable.value = ""
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testArrayMap() {
        let observable = Observable(["one", "two", "three"])
        let mapped: Observable<[Int]> = observable.map { $0.count }
        let asyncExpectation = expectation(description: "Expect to call")
        mapped.bind(self) { old, new in
            guard old == [3, 3, 5] else { return }
            guard new == [4] else { return }
            asyncExpectation.fulfill()
        }
        observable.value = ["four"]
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCompactMap() {
        let observable = Observable(["test", "test", nil])
        let compactMapped = observable.compactMap { $0 }
        let asyncExpectation = expectation(description: "Expect not call")
        asyncExpectation.isInverted = true
        compactMapped.bind(self) { value in
            guard value == ["test", "test", "test"] else { return }
            asyncExpectation.fulfill()
        }
        observable.value.append("test")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testReduce() {
        let observable = Observable(["test", "test"])
        let reduced = observable.reduce(0) { $0 + $1.count }
        let asyncExpectation = expectation(description: "Expect to call")
        reduced.bind(self) { value in
            guard value == 12 else { return }
            asyncExpectation.fulfill()
        }
        observable.value.append("test")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFilter() {
        let observable = Observable(["test", "test", "notTest"])
        let filtered = observable.filter { $0 == "test" }
        let asyncExpectation = expectation(description: "Expect to call")
        filtered.bind(self) { value in
            guard value.count == 3 else { return }
            asyncExpectation.fulfill()
        }
        observable.value.append("test")
        waitForExpectations(timeout: 1, handler: nil)
    }

    static var allTests = [
        ("testMap", testMap),
        ("testArrayMap", testArrayMap),
        ("testCompactMap", testCompactMap),
        ("testReduce", testReduce),
        ("testFilter", testFilter)
    ]
}
