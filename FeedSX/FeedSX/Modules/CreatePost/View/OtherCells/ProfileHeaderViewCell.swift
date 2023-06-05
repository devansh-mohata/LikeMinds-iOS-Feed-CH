//
//  ProfileHeaderViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import UIKit

class ProfileHeaderViewCell: UITableViewCell {
    
    static let cellIdentifier = "ProfileHeaderViewCell"
//    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    var profileContainerView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .white
        uiView.clipsToBounds = true
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let profileImageAndNameStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let profileImageView: UIImageView = {
        let imageSize = 48.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        imageView.drawCornerRadius(radius: CGSize(width: imageSize, height: imageSize))
        return imageView
    }()
    
    let userNameLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Name label"
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        self.contentView.addSubview(profileContainerView)
        profileContainerView.addConstraints(equalToView: self.contentView, top: 10, bottom: -10, left: 0, right: 0)
        profileImageAndNameStackView.addArrangedSubview(profileImageView)
        profileImageAndNameStackView.addArrangedSubview(userNameLabel)
        
        profileContainerView.addSubview(profileImageAndNameStackView)
        profileImageAndNameStackView.addConstraints(equalToView: profileContainerView, top: 5, bottom: -5, left: 16, right: -10)
    }
    
    func setupCellData(_ profileUrl: String, name: String) {
        userNameLabel.text = name
        let profilePlaceHolder = UIImage.generateLetterImage(with: name) ?? UIImage()
        guard let url = profileUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            profileImageView.image = profilePlaceHolder
            return
        }
        profileImageView.kf.setImage(with: URL(string: url), placeholder: profilePlaceHolder)
    }

}
