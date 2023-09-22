//
//  TopicViewCollectionCell.swift
//  FeedSX
//
//  Created by Devansh Mohata on 20/09/23.
//

import UIKit

final class TopicViewCollectionCell: UICollectionViewCell {
    struct ViewModel: LMTopicViewDataProtocol {
        let image: String?
        let title: String?
        var isEditCell: Bool = false
    }
    
    @IBOutlet private var topicStackView: UIStackView!
    @IBOutlet private var editIcon: UIImageView! {
        didSet {
            editIcon.tintColor = LMBranding.shared.buttonColor
        }
    }
    @IBOutlet private var textLbl: LMLabel! {
        didSet {
            textLbl.font = LMBranding.shared.font(14, .regular)
            textLbl.textColor = LMBranding.shared.buttonColor
        }
    }
    
    static let identifier = "TopicViewCollectionCell"
    
    private var callback: (() -> Void)?
    
    override func awakeFromNib() {
        backgroundColor = LMBranding.shared.buttonColor.withAlphaComponent(0.1)
        layer.cornerRadius = 4
        topicStackView.spacing = .zero
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    func configure(with data: ViewModel, callback: (() -> Void)?) {
        self.callback = callback
        
        editIcon.image = UIImage(systemName: data.image ?? "")
        editIcon.isHidden = data.image == nil
        textLbl.text = data.title
        textLbl.isHidden = data.title == nil
    }
    
    @objc
    private func didTapView() {
        callback?()
    }
}
