//
//  HomeFeedDocumentTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 23/05/23.
//

import UIKit

class HomeFeedDocumentTableViewCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedDocumentTableViewCell"
    static let bundle = Bundle(for: HomeFeedDocumentTableViewCell.self)
    weak var delegate: HomeFeedTableViewCellDelegate?
    
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var actionsSectionView: UIView!
    @IBOutlet weak var captionLabel: LMTextView!
    @IBOutlet weak var imageVideoCollectionView: UICollectionView!
    @IBOutlet weak var captionSectionView: UIView!
    @IBOutlet weak var moreAttachmentButton: LMButton!
    @IBOutlet weak var collectionSuperViewHeightConstraint: NSLayoutConstraint!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.captionLabel.tintColor = LMBranding.shared.textLinkColor
        setupImageCollectionView()
        setupProfileSectionHeader()
        setupActionSectionFooter()
        let textViewTapGesture = LMTapGesture(target: self, action: #selector(tappedTextView(tapGesture:)))
        captionLabel.isUserInteractionEnabled = true
        captionLabel.addGestureRecognizer(textViewTapGesture)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc func tappedTextView(tapGesture: LMTapGesture) {
        guard let textView = tapGesture.view as? LMTextView else { return }
        guard let position = textView.closestPosition(to: tapGesture.location(in: textView)) else { return }
        if let url = textView.textStyling(at: position, in: .forward)?[NSAttributedString.Key.link] as? URL {
            UIApplication.shared.open(url)
        } else {
            delegate?.didTapOnCell(self.feedData)
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
    
    fileprivate func setupCaptionSectionView() {
        //        self.captionSectionView.addSubview(postCaptionView)
        //        postCaptionView.addConstraints(equalToView: self.captionSectionView)
    }
    
    @objc func moreButtonClick() {
        let count = self.feedData?.attachments?.count ?? 0
        self.tableView()?.beginUpdates()
        self.collectionSuperViewHeightConstraint.constant = CGFloat(90 * count)
        self.moreAttachmentButton.superview?.isHidden = true
        self.tableView()?.endUpdates()
        
    }
    
    func setupFeedCell(_ feedDataView: PostFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?) {
        self.feedData = feedDataView
        self.delegate = delegate
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        setupCaption()
        let count = self.feedData?.attachments?.count ?? 0
        self.collectionSuperViewHeightConstraint.constant = CGFloat(90 * (count > 2 ? 2 : count))
        if count > 2 {
            self.moreAttachmentButton.superview?.isHidden = false
            self.moreAttachmentButton.setTitle("+\(count - 2) More", for: .normal)
        } else {
            self.moreAttachmentButton.superview?.isHidden = true
        }
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupContainerData()
    }
    
    func setupImageCollectionView() {
        
        self.imageVideoCollectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)
        
        self.moreAttachmentButton.superview?.isHidden = true
        imageVideoCollectionView.dataSource = self
        imageVideoCollectionView.delegate = self
        self.moreAttachmentButton.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        self.moreAttachmentButton.setTitleColor(LMBranding.shared.buttonColor, for: .normal)
    }
    
    private func setupContainerData() {
        switch self.feedData?.postAttachmentType() ?? .unknown {
        case .document:
//            let flowlayout = UICollectionViewFlowLayout()
//            flowlayout.scrollDirection = .vertical
//            flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 90)
//            self.imageVideoCollectionView.collectionViewLayout = flowlayout
            containerView.isHidden = false
            imageVideoCollectionView.reloadData()
        default:
            containerView.isHidden = true
        }
    }
    
    private func setupCaption() {
        let caption = self.feedData?.caption ?? ""
        self.captionLabel.text = caption
        self.captionSectionView.isHidden = caption.isEmpty
        self.captionLabel.attributedText = TaggedRouteParser.shared.getTaggedParsedAttributedString(with: caption, forTextView: true, withTextColor: ColorConstant.postCaptionColor)
    }
    
}

extension HomeFeedDocumentTableViewCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.feedData?.postAttachmentType() ?? .unknown {
        case .document:
            let count = self.feedData?.attachments?.count ?? 0
            return count// > 2 ? 2 : count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var defaultCell = UICollectionViewCell()
      if let attachmentItem = self.feedData?.attachments?[indexPath.row],
                  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
            cell.setupDocumentCell(attachmentItem.attachmentName(), documentDetails: attachmentItem.attachmentDetails())
            cell.removeButton.alpha = 0
            defaultCell = cell
        }
        return defaultCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.feedData?.postAttachmentType() ?? .unknown {
        case .document:
            return CGSize(width: UIScreen.main.bounds.width, height: 90)
        default:
            break
        }
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let attachmentItem = self.feedData?.attachments?[indexPath.row],
           let docUrl = attachmentItem.attachmentUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: docUrl) {
            UIApplication.shared.open(url)
        }
    }
    
}

