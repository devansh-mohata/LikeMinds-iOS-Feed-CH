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
    
    @IBOutlet private weak var imageContainerView: UIView!
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
    @IBOutlet private weak var linkTitleLabel: LMPaddedLabel!
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
        linkTitleLabel.isHidden = true
        linkDescriptionLabel.isHidden = true
        linkTitleLabel.paddingTop = 8
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
        linkTitleLabel.isHidden = true
        linkDescriptionLabel.isHidden = true
        if let link, let url = URL(string: link.linkWithSchema()) {
            linkLabel.text = url.domainUrl()
        }
        playVideoIcon.isHidden = link?.youtubeVideoID() == nil
      imageContainerView.isHidden = linkThumbnailUrl?.isEmpty != false

        let placeholder = UIImage(named: "link_icon", in: Bundle(for: HomeFeedLinkTableViewCell.self), with: nil)
        linkThumbnailImageView.kf.setImage(with: URL.url(string: linkThumbnailUrl ?? "")) {[weak self] result in
            switch result {
            case .success:
                self?.imageContainerView.isHidden = false
                break
            case .failure:
                self?.imageContainerView.isHidden = true
                self?.tableView()?.beginUpdates()
                self?.tableView()?.endUpdates()
                break
            }
            self?.containerView.layoutIfNeeded()
        }
        containerView.layoutIfNeeded()
    }
}
