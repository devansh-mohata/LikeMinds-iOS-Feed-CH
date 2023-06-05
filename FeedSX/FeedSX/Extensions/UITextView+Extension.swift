//
//  UITextView+Extension.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/05/23.
//

import Foundation
import UIKit

extension UITextView {
    
    func trimmedText() -> String {
        return self.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
