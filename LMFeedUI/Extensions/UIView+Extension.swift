//
//  UIView+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 29/03/23.
//

import Foundation
import UIKit

extension UIView {
    
    func setSizeConstraint(width: CGFloat, height: CGFloat) {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func addConstraints(equalToView: UIView, top: CGFloat = 0, bottom: CGFloat = 0,  left: CGFloat = 0, right: CGFloat = 0) {
        self.leftAnchor.constraint(equalTo: equalToView.leftAnchor, constant: left).isActive = true
        self.rightAnchor.constraint(equalTo: equalToView.rightAnchor, constant: right).isActive = true
        self.topAnchor.constraint(lessThanOrEqualTo: equalToView.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(greaterThanOrEqualTo: equalToView.bottomAnchor, constant: bottom).isActive = true
    }
    
    func drawCornerRadius(radius: CGSize) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.allCorners], cornerRadii: radius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addLine(position: String, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case "top":
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case "bottom":
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        default:
            break
        }
    }
    
}
