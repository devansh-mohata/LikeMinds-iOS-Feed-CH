//
//  UITableViewCell+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 24/05/23.
//

import Foundation
import UIKit

extension UITableViewCell {
    func tableView() -> UITableView? {
        var view = self.superview
        while view != nil && (view is UITableView) == false {
            view = view?.superview
        }
        return (view as? UITableView)
    }
}
