//
//  Bindy+UIView.swift
//  Bindy
//
//  Created by Maxim Kotliar on 12/16/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
#if os(iOS)
import UIKit

public extension UIView {
    var bind: Bindable<UIView> {
        return Bindable(base: self)
    }
}

public struct Animation {
    let duration: TimeInterval
    let options: UIView.AnimationOptions

    public init(duration: TimeInterval, options: UIView.AnimationOptions = []) {
        self.duration = duration
        self.options = options
    }
}

public extension Property where Parent == UIView {
    func bind(to observable: Observable<Type>, with animation: Animation) {
        observable.observe(parent) { value in
            UIView.animate(withDuration: animation.duration,
                           delay: 0,
                           options: animation.options,
                           animations: {
                            self.update(value)
            }, completion: nil)
        }
    }

    func to(_ observable: Observable<Type>, with animation: Animation) {
        bind(to: observable, with: animation)
    }
}

extension Bindable where Base == UIView {
    public var isHidden: Property<UIView, Bool> {
        return Property<UIView, Bool> (parent: base) { [unowned base] value in
            base.isHidden = value
        }
    }

    public var alpha: Property<UIView, CGFloat> {
        return Property<UIView, CGFloat> (parent: base) { [unowned base] value in
            base.alpha = value
        }
    }

    public var isUserInteractionEnabled: Property<UIView, Bool> {
        return Property<UIView, Bool> (parent: base) { [unowned base] value in
            base.isUserInteractionEnabled = value
        }
    }

    public var tintColor: Property<Base, UIColor> {
        return Property<Base, UIColor> (parent: base) { [unowned base] value in
            base.tintColor = value
        }
    }

    public var backgroundColor: Property<Base, UIColor> {
        return Property<Base, UIColor> (parent: base) { [unowned base] value in
            base.backgroundColor = value
        }
    }

    public var transform: Property<Base, CGAffineTransform> {
        return Property<Base, CGAffineTransform> (parent: base) { [unowned base] value in
            base.transform = value
        }
    }
}
#endif
