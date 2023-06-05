//
//  RoundButton.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 06/05/23.
//

import Foundation
import UIKit

@IBDesignable
class RoundButton: LMButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
