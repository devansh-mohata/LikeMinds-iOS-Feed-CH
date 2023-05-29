//
//  ActionsFooterView.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 02/04/23.
//

import UIKit

enum CellActionType: String {
    case like
    case likeCount
    case savePost
    case sharePost
    case comment
    case commentCount
    case more
}

protocol ActionsFooterViewDelegate: HomeFeedTableViewCellDelegate {
    func didTappedAction(withActionType actionType: CellActionType, postData: PostFeedDataView?)
}

class ActionsFooterView: UIView {
    
    private weak var delegate: ActionsFooterViewDelegate?
    
    let likeAndCommentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let likeImgAndLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let likeImageView: UIImageView = {
        let imageSize = 25.0
        let imageView = UIImageView()
//        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.likeIcon)
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        return imageView
    }()
    
    let likeCountLabel: UILabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.likeTextColor
        label.font = LMBranding.shared.font(14, .regular)
        label.text = "Like"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let commentImgAndLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let commentImageView: UIImageView = {
        let imageSize = 25.0
        let imageView = UIImageView()
//        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.commentIcon)
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        return imageView
    }()
    
    let commentCountLabel: UILabel = {
        let label = LMLabel()
        label.textColor = ColorConstant.likeTextColor
        label.font = LMBranding.shared.font(14, .regular)
        label.text = "Add comment"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let savedAndShareStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()

    let savedImageView: UIImageView = {
        let imageSize = 20.0
        let imageView = UIImageView()
//        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.bookmarkIcon)
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        return imageView
    }()
    
    let shareImageView: UIImageView = {
        let imageSize = 25.0
        let imageView = UIImageView()
//        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.shareIcon)
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
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
        addSubview(likeAndCommentStackView)
        likeImgAndLabelStackView.addArrangedSubview(likeImageView)
        likeImgAndLabelStackView.addArrangedSubview(likeCountLabel)
        likeAndCommentStackView.addArrangedSubview(likeImgAndLabelStackView)
        commentImgAndLabelStackView.addArrangedSubview(commentImageView)
        commentImgAndLabelStackView.addArrangedSubview(commentCountLabel)
        likeAndCommentStackView.addArrangedSubview(commentImgAndLabelStackView)
    
        addSubview(savedAndShareStackView)
        savedAndShareStackView.addArrangedSubview(savedImageView)
        savedAndShareStackView.addArrangedSubview(shareImageView)
                
        likeAndCommentStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        savedAndShareStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        let topAndBottomMargin = 10.0
        likeAndCommentStackView.rightAnchor.constraint(lessThanOrEqualTo: savedAndShareStackView.leftAnchor, constant: -topAndBottomMargin).isActive = true
        likeAndCommentStackView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor, constant: -topAndBottomMargin).isActive = true
        likeAndCommentStackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: topAndBottomMargin).isActive = true
        
        savedAndShareStackView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor, constant: -topAndBottomMargin).isActive = true
        savedAndShareStackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: topAndBottomMargin).isActive = true
    }
    
    private func setupActions() {
        let likeCountsTapGesture = LMTapGesture(target: self, action: #selector(self.likeCountsTapped(sender:)))
        let likeTapGesture = LMTapGesture(target: self, action: #selector(self.likeTapped(sender:)))
        let bookmarkTapGesture = LMTapGesture(target: self, action: #selector(self.saveTapped(sender:)))
        let shareTapGesture = LMTapGesture(target: self, action: #selector(self.shareTapped(sender:)))
        let commentTapGesture = LMTapGesture(target: self, action: #selector(self.commentTapped(sender:)))
        let commentImageTapGesture = LMTapGesture(target: self, action: #selector(self.commentTapped(sender:)))
        
        likeImageView.isUserInteractionEnabled = true
        likeImageView.addGestureRecognizer(likeTapGesture)
        likeCountLabel.isUserInteractionEnabled = true
        likeCountLabel.addGestureRecognizer(likeCountsTapGesture)
        savedImageView.isUserInteractionEnabled = true
        savedImageView.addGestureRecognizer(bookmarkTapGesture)
        shareImageView.isUserInteractionEnabled = true
        shareImageView.addGestureRecognizer(shareTapGesture)
        commentCountLabel.isUserInteractionEnabled = true
        commentCountLabel.addGestureRecognizer(commentTapGesture)
        commentImageView.isUserInteractionEnabled = true
        commentImageView.addGestureRecognizer(commentImageTapGesture)
    }
    
    @objc private func shareTapped(sender: LMTapGesture) {
        print("Share Button Tapped")
        delegate?.didTappedAction(withActionType: .sharePost, postData: self.feedData)
    }
    
    @objc private func saveTapped(sender: LMTapGesture) {
        print("Bookmark Button Tapped")
        delegate?.didTappedAction(withActionType: .savePost, postData: self.feedData)
        self.feedData?.isSaved = !(self.feedData?.isSaved ?? false)
        savedDataView()
    }
    
    @objc private func likeTapped(sender: LMTapGesture) {
        print("like Button Tapped")
        delegate?.didTappedAction(withActionType: .like, postData: self.feedData)
        let isLike = !(self.feedData?.isLiked ?? false)
        self.feedData?.isLiked = isLike
        self.feedData?.likedCount += isLike ? 1 : -1
        likeDataView()
    }
    
    @objc private func commentTapped(sender: LMTapGesture) {
        print("comment Button Tapped")
        delegate?.didTappedAction(withActionType: .comment, postData: self.feedData)
    }
    
    @objc private func likeCountsTapped(sender: LMTapGesture) {
        print("likecount Button Tapped")
        delegate?.didTappedAction(withActionType: .likeCount, postData: self.feedData)
    }
    
    func setupActionFooterSectionData(_ feedDataView: PostFeedDataView, delegate: HomeFeedTableViewCellDelegate?) {
        self.delegate = delegate as? ActionsFooterViewDelegate
        self.feedData = feedDataView
        likeDataView()
        savedDataView()
        commentCountLabel.text = self.feedData?.commentCounts()
    }
    
    func likeDataView() {
        likeCountLabel.text = self.feedData?.likeCounts()
        if feedData?.isLiked ?? true {
            likeImageView.image = UIImage(systemName: ImageIcon.likeFillIcon)
            likeImageView.tintColor = .red
        } else {
            likeImageView.image = UIImage(systemName: ImageIcon.likeIcon)
            likeImageView.tintColor = .darkGray
        }
    }
    
    func savedDataView() {
        if feedData?.isSaved ?? true {
            savedImageView.image = UIImage(systemName: ImageIcon.bookmarkFillIcon)
        } else {
            savedImageView.image = UIImage(systemName: ImageIcon.bookmarkIcon)
        }
    }
    
}
