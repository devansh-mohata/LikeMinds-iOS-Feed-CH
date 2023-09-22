//
//  ProfileHeaderView.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 02/04/23.
//

import UIKit

protocol ProfileHeaderViewDelegate: HomeFeedTableViewCellDelegate {
    func didTapOnMoreButton(selectedPost: PostFeedDataView?)
}

class ProfileHeaderView: UIView {
    
    weak var delegate: ProfileHeaderViewDelegate?
    
    let avatarAndUsernameStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
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
    
    let usernameAndTimeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .leading
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let usernameAndTitleStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let usernameLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.userNameTextColor
        label.font = LMBranding.shared.font(16, .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let usernameTitleLabel: LMLabel = {
        let label = LMPaddedLabel()
        label.paddingLeft = 8
        label.paddingRight = 8
        label.paddingTop = 2
        label.paddingBottom = 2
        label.textColor = .white
        label.backgroundColor = LMBranding.shared.buttonColor
        label.clipsToBounds = true
        label.layer.cornerRadius = 2.0
        label.font = LMBranding.shared.font(11, .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let designationAtLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.postCaptionColor
        label.font = LMBranding.shared.font(12, .regular)
        label.text = ""
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
    
    let timeLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.postCaptionColor
        label.font = LMBranding.shared.font(12, .regular)
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let editTitleLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.editedTextColor
        label.font = LMBranding.shared.font(12, .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let pinAndActionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .equalCentering
        sv.spacing = 5
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
    
    let moreImageView: UIImageView = {
        let menuImageSize = 30
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.moreIcon)
        imageView.tintColor = .darkGray
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .large)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        avatarAndUsernameStackView.addArrangedSubview(avatarImageView)
        avatarAndUsernameStackView.addArrangedSubview(usernameAndTimeStackView)
        usernameAndTimeStackView.addArrangedSubview(usernameAndTitleStackView)
        usernameAndTitleStackView.addArrangedSubview(usernameLabel)
        usernameAndTitleStackView.addArrangedSubview(usernameTitleLabel)
        usernameAndTimeStackView.addArrangedSubview(designationAtLabel)
        usernameAndTimeStackView.addArrangedSubview(timeAndEditStackView)
        timeAndEditStackView.addArrangedSubview(timeLabel)
        timeAndEditStackView.addArrangedSubview(editTitleLabel)
        
        addSubview(pinAndActionsStackView)
        pinAndActionsStackView.addArrangedSubview(pinImageView)
        pinAndActionsStackView.addArrangedSubview(moreImageView)
        moreImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        moreImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        avatarAndUsernameStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        pinAndActionsStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        
        avatarAndUsernameStackView.rightAnchor.constraint(lessThanOrEqualTo: pinAndActionsStackView.leftAnchor, constant: -10).isActive = true
        
        avatarAndUsernameStackView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor, constant: 0).isActive = true
        avatarAndUsernameStackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 8).isActive = true
        
        pinAndActionsStackView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor, constant: -8).isActive = true
        pinAndActionsStackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupActions() {
        let moreActionTapGesture = LMTapGesture(target: self, action: #selector(self.moreTapped(sender:)))
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(moreActionTapGesture)
        self.moreImageView.isHidden = true
    }
    
    func setupProfileSectionData(_ feedDataView: PostFeedDataView, delegate: HomeFeedTableViewCellDelegate?) {
        self.delegate = delegate as? ProfileHeaderViewDelegate
        self.feedData = feedDataView
        setupProfile(profileData: feedDataView.postByUser)
        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(feedDataView.postTime)).timeAgoDisplayShort()
        pinImageView.isHidden = !(self.feedData?.isPinned ?? false)
        editTitleLabel.text = ""//(feedData?.isEdited ?? false) ? " \(SpecialCharString.centerDot) Edited" : ""
        var organisationDesignaiton = ""
        if let designation = feedDataView.postByUser?.designation, !designation.isEmpty {
            organisationDesignaiton = designation
        }
        if let organisation = feedDataView.postByUser?.organisation, !organisation.isEmpty {
            organisationDesignaiton = organisationDesignaiton + " @ " + organisation
        }
        designationAtLabel.text = organisationDesignaiton
    }
    
    private func setupProfile(profileData: PostFeedDataView.PostByUser?){
        usernameLabel.text = profileData?.name
        usernameTitleSetup(title: profileData?.customTitle)
        let profilePlaceHolder = UIImage.generateLetterImage(with: profileData?.name) ?? UIImage()
        guard let url = profileData?.profileImageUrl else {
            avatarImageView.image = profilePlaceHolder
            return
        }
        avatarImageView.kf.setImage(with: URL(string: url), placeholder: profilePlaceHolder)
    }
    
    private func usernameTitleSetup(title: String?) {
        let customTitle = title ?? ""
        usernameTitleLabel.isHidden = customTitle.isEmpty
        usernameTitleLabel.text = customTitle
    }
    
    @objc private func moreTapped(sender: LMTapGesture) {
        print("More Button Tapped")
        delegate?.didTapOnMoreButton(selectedPost: self.feedData)
    }
}
