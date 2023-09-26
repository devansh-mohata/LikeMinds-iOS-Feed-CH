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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var actionsSectionView: UIView!
    @IBOutlet weak var pdfImageContainerView: UIView!
    @IBOutlet weak var pdfFileName: LMLabel!
    @IBOutlet weak var pdfDetails: LMLabel!
    weak var delegate: HomeFeedTableViewCellDelegate?
    
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

    override func prepareForReuse() {
//        postImageView.image = nil
    }
    
    @objc func tappedPdfImageContainer(tapGesture: LMTapGesture) {
        if let attachmentItem = self.feedData?.attachments?.first,
           let docUrl = attachmentItem.attachmentUrl {
            delegate?.didTapOnUrl(url: docUrl)
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
        self.delegate = delegate
        pdfFileName.text = feedDataView.attachments?.first?.attachmentName()
        pdfDetails.text = feedDataView.attachments?.first?.attachmentDetails()
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupImageView(feedDataView.attachments?.first?.thumbnailUrl)
        self.layoutIfNeeded()
    }
    
    private func setupImageView(_ url: String?) {
        let imagePlaceholder = UIImage(named: "pdf_icon", in: Bundle(for: HomeFeedPDFCell.self), with: nil)
        self.postImageView.image = imagePlaceholder
        guard let url = url, let uRL = URL(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.postImageView.kf.setImage(with: uRL, placeholder: imagePlaceholder)
            }
        }
    }
    
}
