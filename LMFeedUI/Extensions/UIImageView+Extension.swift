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
        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            self.image = placeholder
            return
        }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.kf.setImage(with: URL(string: url), placeholder: placeholder)
            }
        }
    }
    
}
