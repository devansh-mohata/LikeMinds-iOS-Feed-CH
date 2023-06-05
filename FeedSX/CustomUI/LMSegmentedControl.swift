//
//  LMSegmentedControl.swift
//  LikeMindsChat
//
//  Created by Pushpendra Singh on 06/10/22.
//

import UIKit

class LMSegmentedControl: UISegmentedControl {
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
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.font] = LMBranding.shared.font( 17, .medium)
        self.setTitleTextAttributes(attributes, for: .normal)
        var attributes2 = self.titleTextAttributes(for: state) ?? [:]
        attributes2[.font] = LMBranding.shared.font( 17, .medium)
        self.setTitleTextAttributes(attributes, for: .selected)
    }

}
