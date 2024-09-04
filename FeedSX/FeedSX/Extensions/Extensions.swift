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

class FeedSXBundle {}

extension Bundle {
    private static var bundle: Bundle?
    
    static var normal_module: Bundle? = {
        Bundle(for: FeedSXBundle.self)
    }()
    
    static var spm_module: Bundle? = {
        return Bundle(for: FeedSXBundle.self)
    }()
    
    static var lmBundle: Bundle? = {
        Bundle(for: FeedSXBundle.self)
            .url(forResource: "FeedSX", withExtension: "bundle")
            .flatMap(Bundle.init(url:)) ?? Bundle(for: FeedSXBundle.self)
    }()
    
    static var LMImageEditorBundle: Bundle? {
        return lmBundle ?? (normal_module ?? spm_module)
    }
    
}

