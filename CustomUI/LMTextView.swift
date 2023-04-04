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

}
