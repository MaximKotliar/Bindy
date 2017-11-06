//
//  BindyTests.swift
//  BindyTests
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import XCTest
@testable import Bindy

class TestListener: NSObject {
    var tag = 0
}

class BindyTests: XCTestCase {

    var observable: Observable<String>?
    var optionalObservable: OptionalObservable<String>?
    var observableArray: ObservableArray<String>?
    var signal: Signal<String>?

    func testObservable() {
        let old = "Test"
        let new = "Test_New"
        let bindCallExpectation = expectation(description: "bind did call")
        observable = Observable(old)
        observable?.bind(self) { (newValue) in
            guard newValue == new else { return }
            bindCallExpectation.fulfill()
        }
        observable?.value = new
        waitForExpectations(timeout: 1, handler: nil)
    }

    var testObservableListener: TestListener? = TestListener()
    func testObservableCleanup() {
        observable = Observable("testString")

        let bindNotCallExpectation = expectation(description: "bind did not call")
        bindNotCallExpectation.isInverted = true

        observable!.bind(testObservableListener!) { newValue in
            self.testObservableListener!.tag = 3
            bindNotCallExpectation.fulfill()
        }
        // Force listener to release
        testObservableListener = nil
        // Perform change
        observable?.value = "testObservableCleanup"
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalObservable() {
        let old = "Test"
        let new: String? = nil
        let asyncExpectation = expectation(description: "")
        optionalObservable = OptionalObservable(old)
        optionalObservable?.bind(self, callback: { (newValue) in
            guard newValue == new else { return }
            asyncExpectation.fulfill()
        })
        optionalObservable?.value = new
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testObservableArray() {
        let old = ["Test"]
        let new = ["Test", "1", "2", "3", "4"]
        let oldValueExpectation = expectation(description: "oldValue")
        let newValueExpectation = expectation(description: "newValue")
        observableArray = ObservableArray(old)
        observableArray?.bind(self, callback: { (change) in
            if change.oldValue == old {
                oldValueExpectation.fulfill()
            }
            if change.newValue == new {
                newValueExpectation.fulfill()
            }
        })
        observableArray?.append(contentsOf: ["1", "2", "3", "4"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSignal() {
        let testSignal = "Test"
        let asyncExpectation = expectation(description: "Got signal")
        signal = Signal<String>()
        signal?.bind(self) { (recieved) in
            guard recieved == testSignal else {
                return
            }
            asyncExpectation.fulfill()
        }
        signal?.send(testSignal)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testArrayUpdates() {
        let array = ObservableArray(["1", "2", "3", "4", "5"])
        var insertions: [Int] = []
        var replacements: [Int] = []
        array.observe(self) { (change) in
            XCTAssert(change.newValue == ["1", "2", "3", "4", "5"])
        }
        array.unbind(self)
        array.updates.bind(self) { (updates) in
            updates.forEach({ (update) in
                switch update.event {
                case .insert:
                    insertions = update.indexes
                case .replace:
                    replacements = update.indexes
                default:
                    break
                }
            })
        }
        array.replaceAll(with: ["5", "4", "3", "2", "1", "0"])
        XCTAssert(insertions == [5] && replacements == [0, 1, 3, 4])
    }
}
