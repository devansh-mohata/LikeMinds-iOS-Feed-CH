//
//  LMTextView.swift
//  LikeMindsChat
//
//  Created by Pushpendra Singh on 04/10/22.
//

import UIKit

class LMTextView: UITextView {

    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        initialSetup()
    }
    
    private func initialSetup() {
        self.font = font?.brandingFont()
    }

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    
}
