//
//  File.swift
//  
//
//  Created by Alexander Karpov on 21.01.2021.
//

import XCTest
@testable import Bindy

final class ObservablesTests: XCTestCase {

    var observable: Observable<String>?
    var testObservableListener: TestListener?
    var observableArray: ObservableArray<String>?
    var optionalObservable: Observable<String?>?
    
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

    
    func testObservableCleanup() {
        testObservableListener = TestListener()
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
        optionalObservable = Observable(old)
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
        let newValueExpectation = expectation(description: "newValue")
        observableArray = ObservableArray(old)
        observableArray?.bind(self, callback: { (newValue) in
            if newValue == new {
                newValueExpectation.fulfill()
            }
        })
        observableArray?.append(contentsOf: ["1", "2", "3", "4"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    static var allTests = [
        ("testObservable", testObservable),
        ("testObservableCleanup", testObservableCleanup),
        ("testOptionalObservable", testOptionalObservable),
        ("testObservableArray", testObservableArray)
    ]
}
