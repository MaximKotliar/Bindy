//
//  UIObservationsTests.swift
//  
//
//  Created by Alexander Karpov on 21.01.2021.
//

import XCTest
@testable import Bindy

final class UIObservationsTests: XCTestCase {

    func testUIViewIsHidden() {
        let isHidden = Observable(false)
        var view: UIView? = UIView()
        view?.bind.isHidden.to(isHidden)
        isHidden.value = true
        XCTAssert(view?.isHidden == true)
        isHidden.value = false
        XCTAssert(view?.isHidden == false)
        isHidden.value = true
        XCTAssert(view?.isHidden == true)
        isHidden.unbind(view!)
        view?.bind.isHidden.to(isHidden, inverted: true)
        isHidden.value = false
        XCTAssert(view?.isHidden == true)
        view = nil
        isHidden.value = false
    }

    func testUIViewIsUserInteractionEnabled() {
        let isUserInteractionEnabled = Observable(false)
        var view: UIView? = UIView()
        view?.bind.isUserInteractionEnabled.to(isUserInteractionEnabled)
        isUserInteractionEnabled.value = true
        XCTAssert(view?.isUserInteractionEnabled == true)
        isUserInteractionEnabled.value = false
        XCTAssert(view?.isUserInteractionEnabled == false)
        isUserInteractionEnabled.value = true
        XCTAssert(view?.isUserInteractionEnabled == true)
        view = nil
        isUserInteractionEnabled.value = false
    }

    func testUIViewAlpha() {
        let view = UIView()
        let alpha = Observable<CGFloat>(0)
        view.bind.alpha.to(alpha)
        XCTAssert(view.alpha == alpha.value)
        alpha.value = 0.5
        XCTAssert(view.alpha == alpha.value)
    }
    
    static var allTests = [
        ("testUIViewIsHidden", testUIViewIsHidden),
        ("testUIViewIsUserInteractionEnabled", testUIViewIsUserInteractionEnabled),
        ("testUIViewAlpha", testUIViewAlpha)
    ]
}
