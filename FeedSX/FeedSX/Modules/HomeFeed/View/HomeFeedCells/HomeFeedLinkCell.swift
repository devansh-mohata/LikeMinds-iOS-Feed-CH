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
    
    @IBOutlet private weak var youtubeContainerView: UIView!
    @IBOutlet private weak var youtubePlayer: YTPlayerView!
    @IBOutlet private weak var youtubeIndicator: UIActivityIndicatorView!
    
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
    
    private let ytPlayerVars = ["rel" : 0,
                              "showinfo": 0,
                              "disablekb": 1]
    
    var feedData: PostFeedDataView?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        linkTitleLabel.textColor = ColorConstant.textBlackColor
        
        setupProfileSectionHeader()
        setupActionSectionFooter()
        
        youtubePlayer.delegate = self
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
    
    func pauseVideo() {
        youtubePlayer.pauseVideo()
    }
    
    func playVideo() {
        youtubePlayer.playVideo()
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
        youtubeContainerView.isHidden = true
        containerView.isHidden = true
        
        linkTitleLabel.text = title
        linkDescriptionLabel.text = nil
        linkLabel.text = link?.lowercased()
        
        if let videoID = link?.youtubeVideoID() {
            youtubeContainerView.isHidden = false
            setupYoutubePlayer(videoID: videoID)
        } else {
            containerView.isHidden = false
            let placeholder = UIImage(named: "link_icon", in: Bundle(for: HomeFeedLinkTableViewCell.self), with: nil)
            self.linkThumbnailImageView.kf.setImage(with: URL.url(string: linkThumbnailUrl ?? ""), placeholder: placeholder)
        }
        
        self.containerView.layoutIfNeeded()
    }
    
    func setupYoutubePlayer(videoID: String) {
        youtubeIndicator.startAnimating()
        youtubePlayer.load(withVideoId: videoID, playerVars: ytPlayerVars)
    }
}

extension HomeFeedLinkCell: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        youtubeIndicator.stopAnimating()
//        playerView.playVideo()
    }
}
