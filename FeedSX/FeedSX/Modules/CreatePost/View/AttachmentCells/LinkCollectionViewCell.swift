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
    @IBOutlet weak var linkThumbnailImageView: UIImageView! {
        didSet{
            linkThumbnailImageView.tintColor = LMBranding.shared.textLinkColor
            linkThumbnailImageView.backgroundColor = LMBranding.shared.textLinkColor.withAlphaComponent(0.05)
        }
    }
    @IBOutlet weak var linkTitleLabel: LMLabel!
    @IBOutlet weak var linkDescriptionLabel: LMLabel!
    @IBOutlet weak var linkLabel: LMLabel!
    @IBOutlet weak var removeButton: LMButton!
    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        self.contentView.bringSubviewToFront(self.removeButton)
        linkDetailContainerView.clipsToBounds = true
        linkThumbnailImageView.contentMode = .scaleAspectFit
    }
    
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        linkTitleLabel.isHidden = true
        linkDescriptionLabel.isHidden = true
        if let link, let url = URL(string: link.linkWithSchema()) {
            linkLabel.text = url.domainUrl()?.lowercased()
        }
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
        let placeHolder = UIImage(systemName: ImageIcon.brokenLinkIcon, withConfiguration: config)
        if let linkThumbnailUrl, !linkThumbnailUrl.isEmpty {
            self.linkThumbnailImageView.kf.setImage(with: URL.url(string: linkThumbnailUrl), placeholder: placeHolder) { [weak self] result in
                guard let self else {return}
                switch result {
                case .success:
                    linkThumbnailImageView.backgroundColor = .white
                    break
                case .failure:
                    linkThumbnailImageView.backgroundColor = LMBranding.shared.textLinkColor.withAlphaComponent(0.05)
                    break
                }
            }
        } else {
            linkThumbnailImageView.image = placeHolder
        }
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }

}
