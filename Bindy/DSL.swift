//
//  DSL.swift
//  Bindy
//
//  Created by Maxim Kotliar on 4/26/18.
//  Copyright © 2018 Maxim Kotliar. All rights reserved.
//

import Foundation

extension Observable where T == Bool {

    public static func &&(lhs: Observable<Bool>, rhs: Observable<Bool>) -> Observable<Bool> {
        return lhs.combined(with: rhs, transform: { $0 && $1 })
    }

    public static func ||(lhs: Observable<Bool>, rhs: Observable<Bool>) -> Observable<Bool> {
        return lhs.combined(with: rhs, transform: { $0 || $1 })
    }
}
