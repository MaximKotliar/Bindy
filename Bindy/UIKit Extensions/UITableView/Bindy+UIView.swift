//
//  Bindy+UIView.swift
//  Bindy
//
//  Created by Maxim Kotliar on 12/16/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import UIKit

public enum Animation {
    case some(duration: TimeInterval)
    case none
}

public extension UIView {

    func bindAlpha(to isHidden: Observable<Bool>,
                   animation: Animation) {
        isHidden.observe(self) { [unowned self] isHidden in
            let performAlphaUpdate = { self.alpha = isHidden ? 0 : 1 }
            switch animation {
            case .some(let duration):
                UIView.animate(withDuration: duration,
                               animations: performAlphaUpdate)
            case .none:
                performAlphaUpdate()
            }
        }
    }

    func bindIsHidden(to isHidden: Observable<Bool>) {
        isHidden.observe(self) { [unowned self] isHidden in
            self.isHidden = isHidden
        }
    }
}
