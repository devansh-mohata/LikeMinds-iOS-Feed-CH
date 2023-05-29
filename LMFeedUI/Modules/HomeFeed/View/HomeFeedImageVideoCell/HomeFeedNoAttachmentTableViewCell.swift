//
//  HomeFeedNoAttachmentTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 05/04/23.
//

import UIKit

class HomeFeedNoAttachmentTableViewCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedNoAttachmentTableViewCell"
    static let bundle = Bundle(for: HomeFeedNoAttachmentTableViewCell.self)
    weak var delegate: HomeFeedTableViewCellDelegate?
    
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var actionsSectionView: UIView!
    @IBOutlet weak var captionLabel: LMTextView!
    @IBOutlet weak var captionSectionView: UIView!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.captionLabel.tintColor = LMBranding.shared.textLinkColor
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setupActionSectionFooter() {
        self.actionsSectionView.addSubview(actionFooterSectionView)
        actionFooterSectionView.addConstraints(equalToView: self.actionsSectionView)
    }
    
    fileprivate func setupProfileSectionHeader() {
        self.profileSectionView.addSubview(profileSectionHeader)
        profileSectionHeader.addConstraints(equalToView: self.profileSectionView)
    }
    
}
