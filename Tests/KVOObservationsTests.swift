//
//  KVOObservationsTests.swift
//  
//
//  Created by Alexander Karpov on 21.01.2021.
//

import XCTest
@testable import Bindy

final class KVOObservationsTests: XCTestCase {

    var testObservableListener: TestListener?
    var kvoObservable: Observable<CGRect>?

    func testKVOObservable() {
        let view = UIView()
        let observable = view.observable(for: \.frame)
        let asyncExpectation = expectation(description: "Expect to call")
        observable.bind(self) { old, new in
            guard old.width == 0 else { return }
            guard new.width == 1 else { return }
            asyncExpectation.fulfill()
        }
        view.frame = CGRect(x: 1, y: 1, width: 1, height: 1)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testKVOObservableCleanup() {
        testObservableListener = TestListener()
        let view = UIView()
        kvoObservable = view[\.frame]

        let bindNotCallExpectation = expectation(description: "bind did not call")
        bindNotCallExpectation.isInverted = true

        kvoObservable!.bind(testObservableListener!) { newValue in
            self.testObservableListener!.tag = 4
            bindNotCallExpectation.fulfill()
        }
        // Force listener to release
        testObservableListener = nil
        // Perform change
        view.frame = CGRect(x: 1, y: 1, width: 1, height: 1)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    static var allTests = [
        ("testKVOObservable", testKVOObservable),
        ("testKVOObservableCleanup", testKVOObservableCleanup)
    ]
}
