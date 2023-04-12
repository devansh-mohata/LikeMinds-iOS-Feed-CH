//
//  CommentHeaderViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 09/04/23.
//

import UIKit

class CommentHeaderViewCell: UITableViewHeaderFooterView {

    static let reuseIdentifier: String = String(describing: CommentHeaderViewCell.self)
    
    let commentHeaderStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 5
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let usernameAndBadgeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let badgeImageView: UIImageView = {
        let imageSize = 18.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        imageView.drawCornerRadius(radius: CGSize(width: imageSize, height: imageSize))
        return imageView
    }()
    
    let usernameLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(14, .bold)
        label.text = "Pushpendra"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var badgeSpaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let commentAndMoreStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    var commentLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 0
        label.font = LMBranding.shared.font(14, .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var spaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let moreImageView: UIImageView = {
        let menuImageSize = 30.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: menuImageSize, height: menuImageSize))
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "ellipsis")
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .large)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: 27, height: 23)
        return imageView
    }()
    
    let likeAndReplyStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let likeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let likeImageView: UIImageView = {
        let imageSize = 20.0
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "suit.heart")
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 15, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        return imageView
    }()
    
    let likeCountLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = .gray
        label.font = LMBranding.shared.font(12, .regular)
        label.text = "Like"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deviderLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .regular)
        label.text = "|"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let replyStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let replyLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = .gray
        label.font = LMBranding.shared.font(12, .regular)
        label.text = "Reply"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let replyCountLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = LMBranding.shared.buttonColor
        label.font = LMBranding.shared.font(12, .regular)
        label.text = "3 Replies"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var replyAndTimeSpaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let timeLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = .gray
        label.font = LMBranding.shared.font(12, .regular)
        label.text = "2h"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() -> Void {
        
//        contentView.addSubview(commentLabel)
        contentView.backgroundColor = .white
        contentView.addSubview(commentHeaderStackView)
        commentHeaderStackView.addArrangedSubview(usernameAndBadgeStackView)
        usernameAndBadgeStackView.addArrangedSubview(usernameLabel)
        usernameAndBadgeStackView.addArrangedSubview(badgeImageView)
        usernameAndBadgeStackView.addArrangedSubview(badgeSpaceView)
        badgeSpaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        commentAndMoreStackView.addArrangedSubview(commentLabel)
        commentAndMoreStackView.addArrangedSubview(spaceView)
        spaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        commentAndMoreStackView.addArrangedSubview(moreImageView)
        commentHeaderStackView.addArrangedSubview(commentAndMoreStackView)
        likeStackView.addArrangedSubview(likeImageView)
        likeStackView.addArrangedSubview(likeCountLabel)
        likeAndReplyStackView.addArrangedSubview(likeStackView)
        likeAndReplyStackView.addArrangedSubview(deviderLabel)
        replyStackView.addArrangedSubview(replyLabel)
        replyStackView.addArrangedSubview(replyCountLabel)
        likeAndReplyStackView.addArrangedSubview(replyStackView)
        likeAndReplyStackView.addArrangedSubview(replyAndTimeSpaceView)
        replyAndTimeSpaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        likeAndReplyStackView.addArrangedSubview(timeLabel)
        commentHeaderStackView.addArrangedSubview(likeAndReplyStackView)
        let g = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            commentHeaderStackView.topAnchor.constraint(equalTo: g.topAnchor),
            commentHeaderStackView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            commentHeaderStackView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            commentHeaderStackView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
        
    }
    
}
