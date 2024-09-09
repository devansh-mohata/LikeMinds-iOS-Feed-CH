//
//  HomeFeedImageCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit

class HomeFeedImageCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedImageCell"
    static let bundle = Bundle.lmBundle
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var postImageView: ScaledHeightImageView!
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
        postImageView.backgroundColor = .black.withAlphaComponent(0.8)
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }
    
    override func prepareForReuse() {
        postImageView.image = nil
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
        let imagePlaceholder = UIImage(named: "imageplaceholder", in: Bundle.lmBundle, with: nil)
        self.postImageView.image = imagePlaceholder
        guard let url = url, let uRL = URL.url(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: uRL, placeholder: imagePlaceholder)
                self?.layoutIfNeeded()
            }
        }
    }

}
