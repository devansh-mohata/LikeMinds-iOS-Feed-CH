//
//  LinkCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class LinkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var linkDetailContainerView: UIView!
    @IBOutlet weak var linkThumbnailImageView: UIImageView!
    @IBOutlet weak var linkTitleLabel: LMLabel!
    @IBOutlet weak var linkDescriptionLabel: LMLabel!
    @IBOutlet weak var linkLabel: LMLabel!
    @IBOutlet weak var removeButton: LMButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
