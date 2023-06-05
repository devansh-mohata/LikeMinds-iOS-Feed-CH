//
//  LikedUserTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 11/04/23.
//

import UIKit

class LikedUserTableViewCell: UITableViewCell {

    static let reuseIdentifier = "LikedUserTableViewCell"
    
    let avatarAndUsernameStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let avatarImageView: UIImageView = {
        let imageSize = 54.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        imageView.drawCornerRadius(radius: CGSize(width: imageSize, height: imageSize))
        return imageView
    }()
    
    let usernameAndTitleStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let usernameLabel: UILabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .medium)
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let usernameTitleLabel: UILabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(14, .regular)
        label.textColor = LMBranding.shared.buttonColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var spaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.contentView.addSubview(avatarAndUsernameStackView)
        avatarAndUsernameStackView.addArrangedSubview(avatarImageView)
        usernameAndTitleStackView.addArrangedSubview(usernameLabel)
        usernameAndTitleStackView.addArrangedSubview(usernameTitleLabel)
        avatarAndUsernameStackView.addArrangedSubview(usernameAndTitleStackView)
        avatarAndUsernameStackView.addArrangedSubview(spaceView)
        spaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        avatarAndUsernameStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16).isActive = true
        avatarAndUsernameStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16).isActive = true
        avatarAndUsernameStackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16).isActive = true
        avatarAndUsernameStackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
    }
    
    func setupUserData(_ likedUserData: LikedUserDataView.LikedUser) {
        self.usernameLabel.text = likedUserData.username
        let userTitle = likedUserData.userTitle.isEmpty ? "" : " • \(likedUserData.userTitle)"
        self.usernameTitleLabel.text = userTitle
        let profilePlaceHolder = UIImage.generateLetterImage(with: likedUserData.username) ?? UIImage()
        guard let url = likedUserData.profileImage.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            avatarImageView.image = profilePlaceHolder
            return
        }
        avatarImageView.kf.setImage(with: URL(string: url), placeholder: profilePlaceHolder)
    }

}
