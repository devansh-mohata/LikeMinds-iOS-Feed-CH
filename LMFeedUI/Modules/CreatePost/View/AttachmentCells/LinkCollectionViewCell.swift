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
    }
    
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        self.linkTitleLabel.text = title
        self.linkDescriptionLabel.text = description
        self.linkLabel.text = link
        guard let url = linkThumbnailUrl?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.linkThumbnailImageView.kf.setImage(with: URL(string: url))
            }
        }
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }

}
