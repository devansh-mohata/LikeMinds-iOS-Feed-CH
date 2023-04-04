//
//  ImageVideoCollectionViewCell1.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 31/03/23.
//

import UIKit
import Kingfisher

class ImageVideoCollectionViewCell1: UICollectionViewCell {
    
    static let cellIdentifier = "ImageVideoCollectionViewCell1"
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.backgroundColor = UIColor.whiteColor()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        postImageView.contentMode = .scaleAspectFit
        postImageView.backgroundColor = .white
        self.contentView.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        postImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        postImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
    }
    
    func setupImageVideoView(_ imageVideoDataView: HomeFeedDataView.ImageVideo) {
        guard let url = imageVideoDataView.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: URL(string: url))
            }
        }
    }

}
