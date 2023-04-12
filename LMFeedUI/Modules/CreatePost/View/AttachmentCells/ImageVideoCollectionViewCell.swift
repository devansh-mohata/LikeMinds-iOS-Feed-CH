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
    
    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        self.contentView.bringSubviewToFront(self.removeButton)
    }
    
    func setupImageVideoView(_ url: String?) {
        guard let url = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: URL(string: url))
            }
        }
        
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }
    
}
