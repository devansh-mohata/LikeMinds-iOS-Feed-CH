//
//  ImageVideoCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "ImageCollectionViewCell"
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: ImageIcon.crossIcon), for: .normal)
        button.tintColor = .darkGray
        button.setPreferredSymbolConfiguration(.init(pointSize: 20, weight: .light, scale: .large), forImageIn: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setSizeConstraint(width: 30, height: 30)
        return button
    }()
    
    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        self.addSubview(postImageView)
        postImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        postImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        postImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        postImageView.addConstraints(equalToView: self.contentView)
        self.addSubview(removeButton)
        removeButton.setTopConstraint(self, constant: 5)
        removeButton.setRightConstraint(self, constant: -5)
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        bringSubviewToFront(self.removeButton)
    }
    
    func setupImageVideoView(_ url: String?) {
        self.postImageView.image = nil
        guard let url = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let uRL = URL(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: uRL)
            }
        }
        
//        AsyncImageLoader.image(for: uRL, completionHandler: { (image) in
//            DispatchQueue.main.async {
//                if let img = image {
//                    self.postImageView.image = img
//                }else{
//                    let dummyImage = UIImage(named: "img_u")
//                    self.postImageView.image = dummyImage
//                }
//            }
//
//        })
        
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }
    
}
