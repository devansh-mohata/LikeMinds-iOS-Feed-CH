//
//  UIAlertController+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 03/04/23.
//

import Foundation
import UIKit

extension UIAlertController {
    
     func addCancelAction(withOptions actionTitle: String, actionHandler: (()->(Void))?) {
         let cancelAction = UIAlertAction(title: actionTitle, style: .cancel) {_ in
             actionHandler?()
         }
        self.addAction(cancelAction)
    }
    
    func addAction(withOptions actionTitle: String, actionHandler: (()->(Void))?) {
        let action = UIAlertAction(title: actionTitle, style: .default) {_ in
            actionHandler?()
        }
        self.addAction(action)
    }
    
}
