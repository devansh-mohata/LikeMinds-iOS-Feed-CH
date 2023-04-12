//
//  DocumentCollectionCellCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class DocumentCollectionCell: UICollectionViewCell {
    
    static let cellIdentifier = "DocumentCollectionCell"
    static let nibName = "DocumentCollectionCell"
    
    @IBOutlet weak var documentContainerView: UIView!
    @IBOutlet weak var docImageView: UIImageView!
    @IBOutlet weak var documentNameLabel: LMLabel!
    @IBOutlet weak var documentDetailLabel: LMLabel!
    @IBOutlet weak var removeButton: LMButton!
    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        self.documentContainerView.backgroundColor = .white
        self.documentContainerView.clipsToBounds = true
        self.documentContainerView.layer.cornerRadius = 8
        self.documentContainerView.layer.borderWidth = 1.0
        self.documentContainerView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.bringSubviewToFront(self.removeButton)
    }

    func setupDocumentCell(_ documentName: String, documentDetails: String) {
        self.documentNameLabel.text = documentName
        self.documentDetailLabel.text = documentDetails
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }
    
}
