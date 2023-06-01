//
//  ReplyCommentTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 09/04/23.
//

import UIKit

protocol ReplyCommentTableViewCellDelegate: AnyObject {
    func didTapActionButton(withActionType actionType: CellActionType, cell: UITableViewCell)
}

class ReplyCommentTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = String(describing: ReplyCommentTableViewCell.self)
    weak var delegate: ReplyCommentTableViewCellDelegate?
    
    let commentHeaderStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 0
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
        imageView.isHidden = true
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
    
    var commentLabel: LMTextView = {
        let label = LMTextView(frame: .zero)
        label.isEditable = false
        label.isScrollEnabled = false
        label.font = LMBranding.shared.font(14, .regular)
        label.tintColor = LMBranding.shared.textLinkColor
        label.textContainer.lineFragmentPadding = 0
        label.textContainerInset = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var spaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let moreImageView: UIImageView = {
        let menuImageSize = 30
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "ellipsis")
        imageView.tintColor = ColorConstant.likeTextColor
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .large)
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        imageView.tintColor = ColorConstant.likeTextColor
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(pointSize: 15, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let likeCountLabel: LMLabel = {
        let label = LMPaddedLabel()
        label.paddingLeft = 5
        label.paddingRight = 5
        label.paddingTop = 5
        label.paddingBottom = 5
        label.textColor = ColorConstant.likeTextColor
        label.font = LMBranding.shared.font(12, .regular)
        label.text = "Like"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var likeAndTimeSpaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let timeLabel: LMLabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.likeTextColor
        label.font = LMBranding.shared.font(12, .regular)
        label.text = "2h"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var comment: PostDetailDataModel.Comment?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        commonInit()
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() -> Void {
        contentView.addSubview(commentHeaderStackView)
        commentHeaderStackView.addArrangedSubview(usernameAndBadgeStackView)
        usernameAndBadgeStackView.addArrangedSubview(usernameLabel)
        usernameAndBadgeStackView.addArrangedSubview(badgeImageView)
        usernameAndBadgeStackView.addArrangedSubview(badgeSpaceView)
        badgeSpaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        commentAndMoreStackView.addArrangedSubview(commentLabel)
        commentAndMoreStackView.addArrangedSubview(spaceView)
        spaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        commentAndMoreStackView.addArrangedSubview(moreImageView)
        commentHeaderStackView.addArrangedSubview(commentAndMoreStackView)
        likeStackView.addArrangedSubview(likeImageView)
        likeStackView.addArrangedSubview(likeCountLabel)
        likeAndReplyStackView.addArrangedSubview(likeStackView)
        likeAndReplyStackView.addArrangedSubview(likeAndTimeSpaceView)
        likeAndTimeSpaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        likeAndReplyStackView.addArrangedSubview(timeLabel)
        commentHeaderStackView.addArrangedSubview(likeAndReplyStackView)
        let g = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            commentHeaderStackView.topAnchor.constraint(equalTo: g.topAnchor),
            commentHeaderStackView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 32),
            commentHeaderStackView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            commentHeaderStackView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
        likeImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        likeImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        moreImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        moreImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupActions() {
        let likeCountsTapGesture = LMTapGesture(target: self, action: #selector(self.likeCountsTapped(sender:)))
        let likeTapGesture = LMTapGesture(target: self, action: #selector(self.likeTapped(sender:)))
        let moreActionTapGesture = LMTapGesture(target: self, action: #selector(self.moreTapped(sender:)))
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(moreActionTapGesture)
        likeImageView.isUserInteractionEnabled = true
        likeImageView.addGestureRecognizer(likeTapGesture)
        likeCountLabel.isUserInteractionEnabled = true
        likeCountLabel.addGestureRecognizer(likeCountsTapGesture)
    }
    
    func setupDataView(comment: PostDetailDataModel.Comment) {
        self.comment = comment
        self.usernameLabel.text = comment.user.name
        self.commentLabel.attributedText = TaggedRouteParser.shared.getTaggedParsedAttributedString(with: comment.text ?? "", forTextView: false, withFont: LMBranding.shared.font(14, .regular))
        self.likeCountLabel.text = comment.likeCounts()
        self.timeLabel.text = Date(timeIntervalSince1970: TimeInterval(comment.createdAt)).timeAgoDisplayShort()
        likeDataView()
    }

    @objc private func likeTapped(sender: LMTapGesture) {
        let isLike = !(self.comment?.isLiked ?? false)
        self.comment?.isLiked = isLike
        self.comment?.likedCount += isLike ? 1 : -1
        delegate?.didTapActionButton(withActionType: .like, cell: self)
        likeDataView()
    }
    
    func likeDataView() {
        likeCountLabel.text = self.comment?.likeCounts()
        if comment?.isLiked ?? true {
            likeImageView.image = UIImage(systemName: ImageIcon.likeFillIcon)
            likeImageView.tintColor = .red
        } else {
            likeImageView.image = UIImage(systemName: ImageIcon.likeIcon)
            likeImageView.tintColor = .darkGray
        }
    }
    
    @objc private func likeCountsTapped(sender: LMTapGesture) {
        delegate?.didTapActionButton(withActionType: .likeCount, cell: self)
    }
    
    @objc private func moreTapped(sender: LMTapGesture) {
        delegate?.didTapActionButton(withActionType: .more, cell: self)
    }

}
