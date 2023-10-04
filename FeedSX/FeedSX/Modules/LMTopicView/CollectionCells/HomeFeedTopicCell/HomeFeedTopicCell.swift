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
    @IBOutlet private weak var closeBtn: UIButton! {
        didSet {
            closeBtn.setTitle(nil, for: .normal)
            closeBtn.setTitle(nil, for: .selected)
            let config = UIImage.SymbolConfiguration(scale: .small)
            closeBtn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
            closeBtn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .selected)
            closeBtn.tintColor = LMBranding.shared.buttonColor
        }
    }
    
    static let identifier = "HomeFeedTopicCell"
    
    private var selectCallback: (() -> Void)?
    private var openSelection: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topicLbl.font = LMBranding.shared.font(16, .regular)
        topicLbl.textColor = LMBranding.shared.buttonColor
        
        layer.cornerRadius = 4
        layer.borderColor = LMBranding.shared.buttonColor.cgColor
        layer.borderWidth = 1
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }

    func configure(with data: ViewModel, selectCallback: (() -> Void)?, openSelection: (() -> Void)?) {
        topicLbl.text = data.topicName
        self.selectCallback = selectCallback
        self.openSelection = openSelection
    }
    
    @objc
    private func didTapView() {
        openSelection?()
    }
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        selectCallback?()
    }
}
