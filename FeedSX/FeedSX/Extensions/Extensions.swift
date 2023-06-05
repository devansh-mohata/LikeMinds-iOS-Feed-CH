//
//  Extensions.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 29/03/23.
//

import Foundation
import UIKit



extension UIImage {
    func resize(size: CGSize) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: size)
        let result = renderer.image { _ in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return result.withRenderingMode(self.renderingMode)
    }
}

