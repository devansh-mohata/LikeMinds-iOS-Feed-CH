//
//  HomeFeedLinkTableViewCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 05/06/23.
//

import UIKit
import youtube_ios_player_helper

class HomeFeedLinkTableViewCell: UITableViewCell {
    static let nibName: String = "HomeFeedLinkTableViewCell"
    static let bundle = Bundle(for: HomeFeedLinkTableViewCell.self)
    weak var delegate: HomeFeedTableViewCellDelegate?
    
    @IBOutlet private weak var youtubeContainerView: UIView!
    @IBOutlet private weak var youtubePlayerView: YTPlayerView!
    @IBOutlet private weak var youtubeIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var profileSectionView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var actionsSectionView: UIView!
    @IBOutlet private weak var captionLabel: LMTextView!
    @IBOutlet private weak var headerLabel: LMTextView!
    @IBOutlet private weak var captionSectionView: UIView!
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
    @IBOutlet private weak var topicFeedView: LMTopicView!
    
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
    
    let postCaptionView: PostCaptionView = {
        let captionView = PostCaptionView()
        captionView.translatesAutoresizingMaskIntoConstraints = false
        return captionView
    }()
    
    var feedData: PostFeedDataView?
    
    private let ytPlayerVars = ["rel" : 0,
                              "showinfo": 0,
                              "disablekb": 1]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        youtubePlayerView.delegate = self
        captionLabel.delegate = self
        
        selectionStyle = .none
        captionLabel.tintColor = LMBranding.shared.textLinkColor
        linkTitleLabel.textColor = ColorConstant.textBlackColor
        
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        youtubePlayerView.pauseVideo()
        youtubeContainerView.isHidden = true
    }
    
    func setupFeedCell(_ feedDataView: PostFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?, isSepratorShown: Bool = true) {
        self.feedData = feedDataView
        self.delegate = delegate
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        setupCaption()
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupLinkCell(feedDataView.linkAttachment?.title, description: feedDataView.linkAttachment?.description, link: feedDataView.linkAttachment?.url, linkThumbnailUrl: feedDataView.linkAttachment?.linkThumbnailUrl)
        topicFeedView.configure(with: feedDataView.topics, isSepratorShown: isSepratorShown)
        topicFeedView.isHidden = feedDataView.topics.isEmpty
        layoutIfNeeded()
    }
    
    func pauseVideo() {
        youtubePlayerView.pauseVideo()
    }
    
    func playVideo() {
        youtubePlayerView.playVideo()
    }
    
    @objc
    private func tappedTextView(tapGesture: LMTapGesture) {
        guard let textView = tapGesture.view as? LMTextView else { return }
        guard let position = textView.closestPosition(to: tapGesture.location(in: textView)) else { return }
        if let url = textView.textStyling(at: position, in: .forward)?[NSAttributedString.Key.link] as? URL {
            delegate?.didTapOnUrl(url: url.absoluteString)
        } else {
            delegate?.didTapOnCell(self.feedData)
        }
    }
    
    @objc
    private func moreButtonClick() {
        self.tableView()?.beginUpdates()
        self.tableView()?.endUpdates()
    }
        
    @IBAction func clickedLinkView(_ sender: UIButton) {
        if let linkAttachment = self.feedData?.linkAttachment,
           let urlString = linkAttachment.url {
            delegate?.didTapOnUrl(url: urlString)
        }
    }
}

extension HomeFeedLinkTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapOnUrl(url: URL.absoluteString)
        return false
    }
}

extension HomeFeedLinkTableViewCell: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        youtubeIndicator.stopAnimating()
//        playerView.playVideo()
    }
}


private extension HomeFeedLinkTableViewCell {
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        youtubeContainerView.isHidden = true
        containerView.isHidden = true
        
        linkTitleLabel.text = title
        linkDescriptionLabel.text = description
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
    
    func setupCaption() {
        let caption = self.feedData?.caption ?? ""
        self.captionLabel.text = caption
        self.headerLabel.text = self.feedData?.header
        self.captionSectionView.isHidden = caption.isEmpty
        self.captionLabel.attributedText = TaggedRouteParser.shared.getTaggedParsedAttributedString(with: caption, forTextView: true, withTextColor: ColorConstant.postCaptionColor)
    }
    
    func setupYoutubePlayer(videoID: String) {
        youtubeIndicator.startAnimating()
        youtubePlayerView.load(withVideoId: videoID, playerVars: ytPlayerVars)
    }
    
    func setupActionSectionFooter() {
        self.actionsSectionView.addSubview(actionFooterSectionView)
        actionFooterSectionView.addConstraints(equalToView: self.actionsSectionView)
    }
    
    func setupProfileSectionHeader() {
        self.profileSectionView.addSubview(profileSectionHeader)
        profileSectionHeader.addConstraints(equalToView: self.profileSectionView)
    }
}
