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
        linkThumbnailImageView.tintColor = .white
        linkDetailContainerView.clipsToBounds = true
        linkThumbnailImageView.contentMode = .scaleAspectFill
    }
    
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        linkTitleLabel.isHidden = true
        linkDescriptionLabel.isHidden = true
        if let link, let url = URL(string: link.linkWithSchema()) {
            linkLabel.text = url.domainUrl()
        }
        let placeHolder = UIImage(systemName: ImageIcon.linkIcon)
        if let linkThumbnailUrl, !linkThumbnailUrl.isEmpty {
            self.linkThumbnailImageView.kf.setImage(with: URL.url(string: linkThumbnailUrl), placeholder: placeHolder)
        } else {
            linkThumbnailImageView.image = placeHolder
        }
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }

}
