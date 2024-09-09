//
//  HomeFeedWithoutResourceCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 11/09/23.
//

import UIKit

class HomeFeedWithoutResourceCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedWithoutResourceCell"
    static let bundle = Bundle.lmBundle
    
    @IBOutlet weak var profileSectionView: UIView!
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
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }
    
    override func prepareForReuse() {
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
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        self.layoutIfNeeded()
    }
    
}
