//
//  HomeFeedTopicCell.swift
//  FeedSX
//
//  Created by Devansh Mohata on 22/09/23.
//

import UIKit

class HomeFeedTopicCell: UICollectionViewCell {
    struct ViewModel {
        let topicName: String
        let topicID: String
    }
    
    @IBOutlet private weak var topicLbl: LMLabel!
    @IBOutlet private weak var xmarkImage: UIImageView!
    
    static let identifier = "HomeFeedTopicCell"
    
    private var selectCallback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xmarkImage.tintColor = LMBranding.shared.buttonColor
        topicLbl.textColor = LMBranding.shared.buttonColor
        
        layer.cornerRadius = 4
        layer.borderColor = LMBranding.shared.buttonColor.cgColor
        layer.borderWidth = 2
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }

    func configure(with data: ViewModel, selectCallback: (() -> Void)?) {
        topicLbl.text = data.topicName
        self.selectCallback = selectCallback
    }
    
    @objc
    private func didTapView() {
        selectCallback?()
    }
}
