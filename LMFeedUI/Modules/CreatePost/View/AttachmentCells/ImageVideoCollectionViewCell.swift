//
//  ImageVideoCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class ImageVideoCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "ImageVideoCollectionViewCell"
    static let nibName = "ImageVideoCollectionViewCell"
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var removeButton: LMButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupImageVideoView(_ imageVideoDataView: HomeFeedDataView.ImageVideo) {
        guard let url = imageVideoDataView.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: URL(string: url))
            }
        }
        self.contentView.bringSubviewToFront(self.removeButton)
    }
}
