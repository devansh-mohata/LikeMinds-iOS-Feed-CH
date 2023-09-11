//
//  EmptyHomeFeedView.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 18/07/23.
//

import UIKit

protocol EmptyHomeFeedViewDelegate: AnyObject {
    func clickedOnNewPostButton()
}

class EmptyHomeFeedView: UIView {

    weak var delegate: EmptyHomeFeedViewDelegate?
    let superStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .center
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()

    let emptyImageView: UIImageView = {
        let imageSize = 25.0
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.docTextImageIcon)
        imageView.tintColor = ColorConstant.likeTextColor
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(pointSize: 40, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let emptyTitleLabel1: UILabel = {
        let label = LMPaddedLabel()
        label.paddingTop = 10
        label.paddingBottom = 5
        label.textColor = ColorConstant.userNameTextColor
        label.font = LMBranding.shared.font(25, .bold)
        label.text = "No post to show"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emptyTitleLabel2: UILabel = {
        let label = LMPaddedLabel()
        label.paddingTop = 5
        label.paddingBottom = 20
        label.textColor = ColorConstant.likeTextColor
        label.font = LMBranding.shared.font(14, .regular)
        label.text = "Be the first on to post here"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let createPostButton: LMButton = {
        let createPost = LMButton()
        createPost.setImage(UIImage(systemName: ImageIcon.calenderBadgePlus), for: .normal)
        createPost.setTitle("NEW RESOURCE", for: .normal)
        createPost.titleLabel?.font = LMBranding.shared.font(14, .medium)
        createPost.tintColor = .white
        createPost.backgroundColor = LMBranding.shared.buttonColor
        createPost.clipsToBounds = true
        createPost.translatesAutoresizingMaskIntoConstraints = false
        return createPost
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        addSubview(superStackView)
        superStackView.addArrangedSubview(emptyImageView)
        superStackView.addArrangedSubview(emptyTitleLabel1)
        superStackView.addArrangedSubview(emptyTitleLabel2)
        superStackView.addArrangedSubview(createPostButton)
        superStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100).isActive = true
        superStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        createPostButton.widthAnchor.constraint(equalToConstant: 170).isActive = true
        createPostButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        createPostButton.setInsets(forContentPadding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), imageTitlePadding: 10)
        createPostButton.layer.cornerRadius = 25
        emptyImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        emptyImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        createPostButton.addTarget(self, action: #selector(newPostButtonClicked), for: .touchUpInside)
    }
    
    @objc func newPostButtonClicked() {
        delegate?.clickedOnNewPostButton()
    }

}
