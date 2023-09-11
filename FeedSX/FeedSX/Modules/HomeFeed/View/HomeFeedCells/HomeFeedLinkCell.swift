//
//  HomeFeedLinkCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit

class HomeFeedLinkCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedLinkCell"
    static let bundle = Bundle(for: HomeFeedLinkCell.self)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var actionsSectionView: UIView!
    @IBOutlet weak var linkDetailContainerView: UIView!
    @IBOutlet weak var linkThumbnailImageView: UIImageView!
    @IBOutlet weak var linkTitleLabel: LMLabel!
    @IBOutlet weak var linkDescriptionLabel: LMLabel!
    @IBOutlet weak var linkLabel: LMLabel!
    
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
        linkDetailContainerView.layer.borderWidth = 1
        linkDetailContainerView.layer.cornerRadius = 8
        linkDetailContainerView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        linkThumbnailImageView.tintColor = ColorConstant.likeTextColor
        linkDetailContainerView.clipsToBounds = true
        linkThumbnailImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func linkButtonClicked(_ sender: Any) {
        if let linkAttachment = self.feedData?.linkAttachment,
           let urlString = linkAttachment.url {
            let myURL:URL? = URL(string: urlString.linkWithSchema())
            guard let url = myURL else { return }
            UIApplication.shared.open(url)
        }
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
//        self.delegate = delegate
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupLinkCell(feedDataView.linkAttachment?.title, description: feedDataView.linkAttachment?.description, link: feedDataView.linkAttachment?.url, linkThumbnailUrl: feedDataView.linkAttachment?.linkThumbnailUrl)
        self.layoutIfNeeded()
    }
    
    func setupLinkCell(_ title: String?, description: String?, link: String?, linkThumbnailUrl: String?) {
        self.linkTitleLabel.text = title
        self.linkDescriptionLabel.text = nil
        self.linkLabel.text = link?.lowercased()
        if let linkThumbnailUrl = linkThumbnailUrl, !linkThumbnailUrl.isEmpty {
            let placeholder = UIImage(named: "link_icon", in: Bundle(for: HomeFeedLinkTableViewCell.self), with: nil)
            self.linkThumbnailImageView.kf.setImage(with: URL(string: linkThumbnailUrl), placeholder: placeholder)
        } else {
            self.linkThumbnailImageView.image = nil
        }
        self.containerView.layoutIfNeeded()
    }
    
}
