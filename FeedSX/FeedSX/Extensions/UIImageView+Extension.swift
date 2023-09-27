//
//  UIImageView+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 03/04/23.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImage(withUrl url: String, placeholder: UIImage? = nil) {
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.kf.setImage(with: URL.url(string: url), placeholder: placeholder)
            }
        }
    }
    
}
