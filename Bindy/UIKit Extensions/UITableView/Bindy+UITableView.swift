//
//  Bindy+UITableView.swift
//  Bindy
//
//  Created by Maxim Kotliar on 12/16/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import UIKit

public extension UITableView {

    public func perform(updates: [ArrayUpdate],
                        in section: Int = 0,
                        insertAnimation: UITableViewRowAnimation = .automatic,
                        deleteAnimation: UITableViewRowAnimation = .automatic,
                        replaceAnimation: UITableViewRowAnimation = .automatic) {
        var insertions: [IndexPath] = []
        var deletions: [IndexPath] = []
        var replacements: [IndexPath] = []
        for update in updates {
            let indexPaths = update.indexes.map { IndexPath(row: $0, section: section) }
            switch update.event {
            case .insert:
                insertions.append(contentsOf: indexPaths)
            case .delete:
                deletions.append(contentsOf: indexPaths)
            case .replace:
                replacements.append(contentsOf: indexPaths)
            }
        }
        beginUpdates()
        insertRows(at: insertions, with: insertAnimation)
        deleteRows(at: deletions, with: deleteAnimation)
        reloadRows(at: replacements, with: replaceAnimation)
        endUpdates()
    }
}
