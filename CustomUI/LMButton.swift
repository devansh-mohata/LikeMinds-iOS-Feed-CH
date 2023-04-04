//
//  LMButton.swift
//  LikeMindsChat
//
//  Created by Pushpendra Singh on 04/10/22.
//

import UIKit

class LMButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        initialSetup()
    }
    
    private func initialSetup() {
        self.titleLabel?.font = titleLabel?.font.brandingFont()
    }

}
