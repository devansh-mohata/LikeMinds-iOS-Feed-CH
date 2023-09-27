//
//  HomeFeedArticleCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit

class HomeFeedArticleCell: UITableViewCell {

    static let nibName: String = "HomeFeedArticleCell"
    static let bundle = Bundle(for: HomeFeedArticleCell.self)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var coverBannerContainerView: UIView!
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var actionsSectionView: UIView!
    var feedData: PostFeedDataView?
    
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        coverBannerContainerView.layer.cornerRadius = 8
        coverBannerContainerView.clipsToBounds = true
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }
    
    override func prepareForReuse() {
        articleImageView.image = nil
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
        //        self.delegate = delegate
        if let imageUrl = feedDataView.imageVideos?.first?.url {
            self.setupImageView(imageUrl)
        }
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        self.layoutIfNeeded()
    }
    
    private func setupImageView(_ url: String?) {
        let imagePlaceholder = UIImage(named: "imageplaceholder", in: Bundle(for: HomeFeedImageCell.self), with: nil)
        self.articleImageView.image = imagePlaceholder
        guard let url = url, let uRL = URL.url(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.articleImageView.kf.setImage(with: uRL, placeholder: imagePlaceholder)
            }
        }
    }
}
