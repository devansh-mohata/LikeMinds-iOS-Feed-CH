//
//  CustomUIImageView.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import Foundation
import UIKit

class ScaledHeightImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = UIScreen.main.bounds.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
//            let height = myViewWidth < scaledHeight ? myViewWidth : scaledHeight
            return CGSize(width: myViewWidth, height: myViewWidth)
        }
        return CGSize(width: -1.0, height: -1.0)
    }
    
}
