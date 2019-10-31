//
//  Helpers.swift
//  Bindy
//
//  Created by Maxim Kotliar on 31.10.2019.
//  Copyright © 2019 Maxim Kotliar. All rights reserved.
//

import Foundation

/// For use in closure where we need explicitly retain unused value
@inlinable func retain(_ value: Any) {
    let _ = value
}
