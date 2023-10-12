//
//  HomeFeedLinkCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit
import youtube_ios_player_helper

class HomeFeedLinkCell: UITableViewCell {
    static let nibName: String = "HomeFeedLinkCell"
    static let bundle = Bundle(for: HomeFeedLinkCell.self)
    
    @IBOutlet private weak var playVideoIcon: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var profileSectionView: UIView!
    @IBOutlet private weak var actionsSectionView: UIView!
    @IBOutlet private weak var linkDetailContainerView: UIView! {
        didSet {
            linkDetailContainerView.layer.borderWidth = 1
            linkDetailContainerView.layer.cornerRadius = 8
            linkDetailContainerView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
            linkDetailContainerView.clipsToBounds = true
        }
    }
    @IBOutlet private weak var linkThumbnailImageView: UIImageView! {
        didSet {
            linkThumbnailImageView.tintColor = ColorConstant.likeTextColor
            linkThumbnailImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet private weak var linkTitleLabel: LMLabel!
    @IBOutlet private weak var linkDescriptionLabel: LMLabel!
    @IBOutlet private weak var linkLabel: LMLabel!
    @IBOutlet private weak var topicFeed: LMTopicView!
    
    weak var delegate: HomeFeedTableViewCellDelegate?
    
    let profileSectionHeader: HomeFeedProfileHeaderView = {
        let profileSection = HomeFeedProfileHeaderView()
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
        linkTitleLabel.textColor = ColorConstant.textBlackColor
        
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }
    
    func setupFeedCell(_ feedDataView: PostFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?) {
        self.feedData = feedDataView
        self.delegate = delegate
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupLinkCell(feedDataView.linkAttachment?.title, description: feedDataView.linkAttachment?.description, link: feedDataView.linkAttachment?.url, linkThumbnailUrl: feedDataView.linkAttachment?.linkThumbnailUrl)
        topicFeed.configure(with: feedDataView.topics, isSepratorShown: false)
        self.layoutIfNeeded()
    }
    
    @IBAction private func linkButtonClicked(_ sender: Any) {
        if let linkAttachment = self.feedData?.linkAttachment,
           let urlString = linkAttachment.url {
            delegate?.didTapOnUrl(url: urlString)
        }
    }
}


private extension HomeFeedLinkCell {
    func setupProfileSectionHeader() {
        self.profileSectionView.addSubview(profileSectionHeader)
        profileSectionHeader.addConstraints(equalToView: self.profileSectionView)
    }
    
    func setupActionSectionFooter() {
        self.actionsSectionView.addSubview(actionFooterSectionView)
        actionFooterSectionView.addConstraints(equalToView: self.actionsSectionView)
    }
    
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        linkTitleLabel.text = title
        linkDescriptionLabel.text = nil
        linkLabel.text = link?.lowercased()
        playVideoIcon.isHidden = link?.youtubeVideoID() == nil
        
        let placeholder = UIImage(named: "link_icon", in: Bundle(for: HomeFeedLinkTableViewCell.self), with: nil)
        linkThumbnailImageView.kf.setImage(with: URL.url(string: linkThumbnailUrl ?? ""), placeholder: placeholder)
        
        containerView.layoutIfNeeded()
    }
}
