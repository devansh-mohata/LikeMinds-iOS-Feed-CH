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
    
    @IBOutlet private weak var profileSectionView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var actionsSectionView: UIView!
    @IBOutlet private weak var captionLabel: LMTextView!
    @IBOutlet private weak var captionSectionView: UIView!
    @IBOutlet private weak var moreAttachmentButton: LMButton!
    @IBOutlet private weak var topicView: LMTopicView!
    @IBOutlet private weak var titleLabel: LMTextView!
    @IBOutlet private weak var pdfFileNameLabel: LMLabel!
    @IBOutlet private weak var pdfDetailsLabel: LMLabel!
    @IBOutlet private weak var pdfThumbnailImage: UIImageView!
    @IBOutlet private weak var pdfImageContainerView: UIView!
    
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
        setupProfileSectionHeader()
        setupActionSectionFooter()
//        let textViewTapGesture = LMTapGesture(target: self, action: #selector(tappedTextView(tapGesture:)))
//        captionLabel.isUserInteractionEnabled = true
//        captionLabel.addGestureRecognizer(textViewTapGesture)
        captionLabel.delegate = self
        
        let pdfImageTapGesture = LMTapGesture(target: self, action: #selector(tappedPdfImageContainer(tapGesture:)))
        pdfImageContainerView.isUserInteractionEnabled = true
        pdfImageContainerView.addGestureRecognizer(pdfImageTapGesture)
        
        self.pdfImageContainerView.layer.cornerRadius = 10
        self.pdfImageContainerView.layer.masksToBounds = true
        self.pdfImageContainerView.layer.borderWidth = 1
        self.pdfImageContainerView.layer.borderColor = ColorConstant.backgroudColor.withAlphaComponent(0.4).cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func tappedTextView(tapGesture: LMTapGesture) {
        guard let textView = tapGesture.view as? LMTextView else { return }
        guard let position = textView.closestPosition(to: tapGesture.location(in: textView)) else { return }
        if let url = textView.textStyling(at: position, in: .forward)?[NSAttributedString.Key.link] as? URL {
            delegate?.didTapOnUrl(url: url.absoluteString)
        } else {
            delegate?.didTapOnCell(self.feedData)
        }
    }
    
    @objc func tappedPdfImageContainer(tapGesture: LMTapGesture) {
        if let attachmentItem = self.feedData?.attachments?.first,
           let docUrl = attachmentItem.attachmentUrl {
            delegate?.didTapOnUrl(url: docUrl)
        }
    }
    
    fileprivate func setupActionSectionFooter() {
        self.actionsSectionView.addSubview(actionFooterSectionView)
        actionFooterSectionView.addConstraints(equalToView: self.actionsSectionView)
    }
    
    private func setupProfileSectionHeader() {
        self.profileSectionView.addSubview(profileSectionHeader)
        profileSectionHeader.addConstraints(equalToView: self.profileSectionView)
    }
        
    func setupFeedCell(_ feedDataView: PostFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?, isSepratorShown: Bool = true) {
        self.feedData = feedDataView
        self.delegate = delegate
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        setupCaption()
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        
        topicView.configure(with: feedDataView.topics, isSepratorShown: isSepratorShown)
        topicView.isHidden = feedDataView.topics.isEmpty
        containerView.isHidden = feedData?.postAttachmentType() != .document
        layoutIfNeeded()

        guard let attachmentItem = feedDataView.attachments?.first else { return }
        self.pdfFileNameLabel.text =  attachmentItem.attachmentName()
        self.pdfDetailsLabel.text = attachmentItem.attachmentDetails()
        self.setupImageView(attachmentItem.thumbnailUrl)
    }

    private func setupImageView(_ url: String?) {
        let imagePlaceholder = UIImage(named: "pdf_icon", in: Bundle(for: HomeFeedDocumentTableViewCell.self), with: nil)
        self.pdfThumbnailImage.image = imagePlaceholder
        guard let url = url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let uRL = URL.url(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.pdfThumbnailImage.kf.setImage(with: uRL, placeholder: imagePlaceholder)
            }
        }
    }
 
    private func setupCaption() {
        let caption = self.feedData?.caption ?? ""
        let header = self.feedData?.header ?? ""
        self.titleLabel.text = header
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
           let docUrl = attachmentItem.attachmentUrl {
            delegate?.didTapOnUrl(url: docUrl)
        }
    }
    
}

extension HomeFeedDocumentTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapOnUrl(url: URL.absoluteString)
        return false
    }
}

