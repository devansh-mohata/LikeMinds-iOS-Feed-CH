//
//  HomeFeedPDFCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit

class HomeFeedPDFCell: UITableViewCell {

    static let nibName: String = "HomeFeedPDFCell"
    static let bundle = Bundle(for: HomeFeedPDFCell.self)
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var profileSectionView: UIView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var actionsSectionView: UIView!
    @IBOutlet private weak var pdfImageContainerView: UIView!
    @IBOutlet private weak var pdfFileName: LMLabel!
    @IBOutlet private weak var pdfDetails: LMLabel!
    @IBOutlet private weak var topicFeed: LMTopicView!
    
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
        self.pdfImageContainerView.layer.cornerRadius = 10
        self.pdfImageContainerView.layer.masksToBounds = true
        self.pdfImageContainerView.layer.borderWidth = 1
        self.pdfImageContainerView.layer.borderColor = ColorConstant.backgroudColor.withAlphaComponent(0.4).cgColor
        let pdfImageTapGesture = LMTapGesture(target: self, action: #selector(tappedPdfImageContainer(tapGesture:)))
        pdfImageContainerView.isUserInteractionEnabled = true
        pdfImageContainerView.addGestureRecognizer(pdfImageTapGesture)
    }
    
    @objc func tappedPdfImageContainer(tapGesture: LMTapGesture) {
        if let attachmentItem = self.feedData?.attachments?.first,
           let docUrl = attachmentItem.attachmentUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: docUrl) {
            UIApplication.shared.open(url)
        }
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
        pdfFileName.text = feedDataView.attachments?.first?.attachmentName()
        pdfDetails.text = feedDataView.attachments?.first?.attachmentDetails()
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupImageView(feedDataView.attachments?.first?.thumbnailUrl)
        topicFeed.configure(with: feedDataView.topics, isSepratorShown: false)
        self.layoutIfNeeded()
    }
    
    private func setupImageView(_ url: String?) {
        let imagePlaceholder = UIImage(named: "pdf_icon", in: Bundle(for: HomeFeedPDFCell.self), with: nil)
        self.postImageView.image = imagePlaceholder
        guard let url = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let uRL = URL(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: uRL, placeholder: imagePlaceholder)
            }
        }
    }
    
}
