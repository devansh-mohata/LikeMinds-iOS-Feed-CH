//
//  HomeFeedProfileHeaderView.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit

protocol HomeFeedProfileHeaderViewDelegate: HomeFeedTableViewCellDelegate {
    func didTapOnMoreButton(selectedPost: PostFeedDataView?)
}

class HomeFeedProfileHeaderView: UIView {
    
    weak var delegate: HomeFeedProfileHeaderViewDelegate?
    
    let avatarAndUsernameStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let pinImageView: UIImageView = {
        let menuImageSize = 24
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: menuImageSize, height: menuImageSize))
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: ImageIcon.pinIcon, in: Bundle(for: ProfileHeaderView.self), with: nil)
        imageView.tintColor = ColorConstant.likeTextColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var pinContainerView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let avatarImageView: UIImageView = {
        let imageSize = 48.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        imageView.drawCornerRadius(radius: CGSize(width: imageSize, height: imageSize))
        return imageView
    }()
    
    let postTitleAndTimeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .leading
        sv.spacing = 2
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let postTitleLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.userNameTextColor
        label.numberOfLines = 2
        label.font = LMBranding.shared.font(16, .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let timeAndEditStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let usernameLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.postCaptionColor
        label.font = LMBranding.shared.font(12, .regular)
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let postTimeLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.postCaptionColor
        label.font = LMBranding.shared.font(12, .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var feedData: PostFeedDataView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        addSubview(avatarAndUsernameStackView)
        pinContainerView.addSubview(pinImageView)
        avatarAndUsernameStackView.addArrangedSubview(avatarImageView)
        avatarAndUsernameStackView.addArrangedSubview(postTitleAndTimeStackView)
        avatarAndUsernameStackView.addArrangedSubview(pinContainerView)
        postTitleAndTimeStackView.addArrangedSubview(postTitleLabel)
        postTitleAndTimeStackView.addArrangedSubview(timeAndEditStackView)
        timeAndEditStackView.addArrangedSubview(usernameLabel)
        timeAndEditStackView.addArrangedSubview(postTimeLabel)
        
        avatarAndUsernameStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        avatarAndUsernameStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        avatarAndUsernameStackView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor, constant: 0).isActive = true
        avatarAndUsernameStackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 8).isActive = true
        
        pinImageView.leftAnchor.constraint(equalTo: pinContainerView.leftAnchor, constant: 0).isActive = true
        pinImageView.rightAnchor.constraint(equalTo: pinContainerView.rightAnchor, constant: 0).isActive = true
        pinImageView.topAnchor.constraint(lessThanOrEqualTo: pinContainerView.topAnchor, constant: 0).isActive = true
        
        pinContainerView.topAnchor.constraint(lessThanOrEqualTo: avatarImageView.topAnchor, constant: 0).isActive = true
        pinContainerView.bottomAnchor.constraint(lessThanOrEqualTo: avatarAndUsernameStackView.bottomAnchor, constant: 0).isActive = true
    }
    
    private func setupActions() {
    }
    
    func setupProfileSectionData(_ feedDataView: PostFeedDataView, delegate: HomeFeedTableViewCellDelegate?) {
//        self.delegate = delegate as? ProfileHeaderViewDelegate
        self.feedData = feedDataView
        setupProfile(profileData: feedDataView.postByUser)
        postTitleLabel.text = feedDataView.header
        postTimeLabel.text = " \(SpecialCharString.centerDot) " + Date(timeIntervalSince1970: TimeInterval(feedDataView.postTime)).timeAgoDisplayShort()// + ((feedData?.isEdited ?? false) ? " \(SpecialCharString.centerDot) Edited" : "")
        pinImageView.isHidden = !feedDataView.isPinned
    }
    
    private func setupProfile(profileData: PostFeedDataView.PostByUser?){
        usernameLabel.text = profileData?.name
        let profilePlaceHolder = UIImage.generateLetterImage(with: profileData?.name) ?? UIImage()
        guard let url = profileData?.profileImageUrl else {
            avatarImageView.image = profilePlaceHolder
            return
        }
        avatarImageView.kf.setImage(with: URL(string: url), placeholder: profilePlaceHolder)
    }

}
