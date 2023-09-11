//
//  LinkCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class LinkCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "LinkCollectionViewCell"
    static let nibName = "LinkCollectionViewCell"
    
    @IBOutlet weak var linkDetailContainerView: UIView!
    @IBOutlet weak var linkThumbnailImageView: UIImageView!
    @IBOutlet weak var linkTitleLabel: LMLabel!
    @IBOutlet weak var linkDescriptionLabel: LMLabel!
    @IBOutlet weak var linkLabel: LMLabel!
    @IBOutlet weak var removeButton: LMButton!
    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        self.contentView.bringSubviewToFront(self.removeButton)
//        linkDetailContainerView.layer.borderWidth = 1
//        linkDetailContainerView.layer.cornerRadius = 8
//        linkDetailContainerView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        linkThumbnailImageView.tintColor = .white
        linkDetailContainerView.clipsToBounds = true
        linkThumbnailImageView.contentMode = .scaleAspectFill
    }
    
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        self.linkTitleLabel.text = title
        self.linkDescriptionLabel.text = description
        self.linkLabel.text = link?.lowercased()
        let placeHolder = UIImage(systemName: ImageIcon.linkIcon)
        if let linkThumbnailUrl, !linkThumbnailUrl.isEmpty {
            self.linkThumbnailImageView.kf.setImage(with: URL(string: linkThumbnailUrl), placeholder: placeHolder)
        } else {
            linkThumbnailImageView.image = placeHolder
        }
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }

}
