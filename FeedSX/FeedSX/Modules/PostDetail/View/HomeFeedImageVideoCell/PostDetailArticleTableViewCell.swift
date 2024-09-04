//
//  PostDetailArticleTableViewCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 07/09/23.
//

import UIKit

class PostDetailArticleTableViewCell: UITableViewCell {
    
    static let nibName: String = "PostDetailArticleTableViewCell"
    static let bundle = Bundle.lmBundle
    weak var delegate: HomeFeedTableViewCellDelegate?
    
    @IBOutlet private weak var profileSectionView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var actionsSectionView: UIView!
    @IBOutlet private weak var headerLabel: LMTextView!
    @IBOutlet private weak var captionLabel: LMTextView!
    @IBOutlet private weak var captionSectionView: UIView!
    @IBOutlet private weak var coverBannerContainerView: UIView!
    @IBOutlet private weak var articleImageView: UIImageView!
    @IBOutlet private weak var topicFeed: LMTopicView!
    
    let profileSectionHeader: ProfileHeaderView = {
        let profileSection = ProfileHeaderView()
        profileSection.translatesAutoresizingMaskIntoConstraints = false
        return profileSection
    }()
    
    let actionFooterSectionView: ActionsFooterView = {
        let actionsSection = ActionsFooterView()
        actionsSection.translatesAutoresizingMaskIntoConstraints = false
        return actionsSection
    }()

    var feedData: PostFeedDataView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.captionLabel.tintColor = LMBranding.shared.textLinkColor
        captionLabel.delegate = self
        headerLabel.textColor = ColorConstant.textBlackColor
        setupProfileSectionHeader()
        setupActionSectionFooter()
        coverBannerContainerView.layer.cornerRadius = 8
        articleImageView.tintColor = ColorConstant.likeTextColor
        coverBannerContainerView.clipsToBounds = true
        articleImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func setupActionSectionFooter() {
        self.actionsSectionView.addSubview(actionFooterSectionView)
        actionFooterSectionView.addConstraints(equalToView: self.actionsSectionView)
    }
    
    fileprivate func setupProfileSectionHeader() {
        self.profileSectionView.addSubview(profileSectionHeader)
        profileSectionHeader.addConstraints(equalToView: self.profileSectionView)
    }
    
    func setupFeedCell(_ feedDataView: PostFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?) {
        self.feedData = feedDataView
        self.delegate = delegate
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        setupCaption()
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        if let imageUrl = feedDataView.imageVideos?.first?.url {
            let placeholder = UIImage(named: "placeholder", in: Bundle.lmBundle, with: nil)
            self.articleImageView.kf.setImage(with: URL.url(string: imageUrl), placeholder: placeholder)
        } else {
            self.articleImageView.image = nil
        }
        
        topicFeed.configure(with: feedDataView.topics, isSepratorShown: false)
        topicFeed.superview?.isHidden = feedDataView.topics.isEmpty
        self.layoutIfNeeded()
    }
    
    private func setupCaption() {
        let caption = self.feedData?.caption ?? ""
        self.captionLabel.text = caption
        self.headerLabel.text = self.feedData?.header
        self.captionSectionView.isHidden = caption.isEmpty
        self.captionLabel.attributedText = TaggedRouteParser.shared.getTaggedParsedAttributedString(with: caption, forTextView: true, withTextColor: ColorConstant.postCaptionColor)
    }
    
}

extension PostDetailArticleTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapOnUrl(url: URL.absoluteString)
        return false
    }
}
