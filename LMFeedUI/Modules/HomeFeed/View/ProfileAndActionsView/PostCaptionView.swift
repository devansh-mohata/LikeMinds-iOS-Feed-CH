//
//  PostCaptionView.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 03/04/23.
//

import Foundation
import UIKit

class PostCaptionView: UIView {
    
    let postCaptionTextView: LMTextView = {
        let textView = LMTextView(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        textView.font = LMBranding.shared.font(16, .regular)
        textView.textColor = .lightGray
        textView.backgroundColor = .red
        textView.text = "ajtoadj fla dflsdfj la"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .yellow
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(postCaptionTextView)
        let leftRightMargin = 16.0
        let topBottomMargin = 0.0
        postCaptionTextView.addConstraints(equalToView: self, top: topBottomMargin, bottom: topBottomMargin, left: leftRightMargin, right: -leftRightMargin)
    }
    
    func setupCaptionSectionData(_ feedDataView: HomeFeedDataView) {
        self.postCaptionTextView.text = "Test caption"//feedDataView.caption
    }
}
