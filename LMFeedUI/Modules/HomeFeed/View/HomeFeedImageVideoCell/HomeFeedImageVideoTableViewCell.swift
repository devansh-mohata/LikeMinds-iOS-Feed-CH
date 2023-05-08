//
//  HomeFeedTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 27/03/23.
//

import UIKit
import Kingfisher

protocol HomeFeedTableViewCellDelegate: AnyObject {
    
}

class HomeFeedImageVideoTableViewCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedImageVideoTableViewCell"
    static let bundle = Bundle(for: HomeFeedImageVideoTableViewCell.self)
    weak var delegate: HomeFeedTableViewCellDelegate?
    
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var actionsSectionView: UIView!
    @IBOutlet weak var captionLabel: LMTextView!
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var pageControlView: UIView?
    @IBOutlet weak var imageVideoCollectionView: UICollectionView!
    @IBOutlet weak var captionSectionView: UIView!
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
        setupImageCollectionView()
        setupProfileSectionHeader()
        setupActionSectionFooter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
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
    
    fileprivate func setupCaptionSectionView() {
//        self.captionSectionView.addSubview(postCaptionView)
//        postCaptionView.addConstraints(equalToView: self.captionSectionView)
    }
    
    func setupFeedCell(_ feedDataView: PostFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?) {
        self.feedData = feedDataView
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        setupCaption()
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupContainerData()
    }
    
    func setupImageCollectionView() {
        
        self.imageVideoCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.cellIdentifier)
        self.imageVideoCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
        self.imageVideoCollectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)
        
        let linkNib = UINib(nibName: "LinkCollectionViewCell", bundle: Bundle(for: LinkCollectionViewCell.self))
        self.imageVideoCollectionView.register(linkNib, forCellWithReuseIdentifier: LinkCollectionViewCell.cellIdentifier)
        
        imageVideoCollectionView.dataSource = self
        imageVideoCollectionView.delegate = self
        
        self.pageControl?.currentPageIndicatorTintColor = LMBranding.shared.buttonColor
    }
    
    private func setupContainerData() {
        switch self.feedData?.postAttachmentType() ?? .unknown {
        case .link:
//            let flowlayout = UICollectionViewFlowLayout()
//            flowlayout.scrollDirection = .vertical
//            flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
//            imageVideoCollectionView.collectionViewLayout = flowlayout
            containerView.isHidden = false
            pageControlView?.isHidden = true
            imageVideoCollectionView.reloadData()
        case .image, .video:
//            let flowlayout = UICollectionViewFlowLayout()
//            flowlayout.scrollDirection = .horizontal
//            flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
//            self.imageVideoCollectionView.collectionViewLayout = flowlayout
            containerView.isHidden = false
            let imageCount = self.feedData?.imageVideos?.count ?? 0
            pageControlView?.isHidden = imageCount < 2
            pageControl?.numberOfPages = imageCount
            imageVideoCollectionView.reloadData()
        case .document:
//            let flowlayout = UICollectionViewFlowLayout()
//            flowlayout.scrollDirection = .vertical
//            flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 90)
//            self.imageVideoCollectionView.collectionViewLayout = flowlayout
            containerView.isHidden = false
            pageControlView?.isHidden = true
            imageVideoCollectionView.reloadData()
        default:
            containerView.isHidden = true
            pageControlView?.isHidden = true
        }
    }
    
    private func setupCaption() {
        let caption = self.feedData?.caption ?? ""
        self.captionLabel.text = caption
        self.captionSectionView.isHidden = caption.isEmpty
        self.captionLabel.attributedText = TaggedRouteParser.shared.getTaggedParsedAttributedString(with: caption, forTextView: true)
    }
    
}

extension HomeFeedImageVideoTableViewCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.feedData?.postAttachmentType() ?? .unknown {
        case .link:
            return 1
        case .image, .video:
            return self.feedData?.imageVideos?.count ?? 0
        case .document:
            let count = self.feedData?.attachments?.count ?? 0
            return count > 3 ? 3 : count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var defaultCell = UICollectionViewCell()
        if let imageVideoItem = self.feedData?.imageVideos?[indexPath.row]{
            switch imageVideoItem.fileType {
            case .image:
                guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.cellIdentifier, for: indexPath) as? ImageCollectionViewCell else { return defaultCell}
                cell.setupImageVideoView(imageVideoItem.url)
                cell.removeButton.alpha = 0
                defaultCell = cell
            case .video:
                guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.cellIdentifier, for: indexPath) as? VideoCollectionViewCell else { return defaultCell}
                cell.setupVideoData(url: imageVideoItem.url ?? "")
                cell.removeButton.alpha = 0
                defaultCell = cell
            default:
                break
            }
           
        } else if let attachmentItem = self.feedData?.attachments?[indexPath.row],
                  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
            cell.setupDocumentCell(attachmentItem.attachmentName(), documentDetails: attachmentItem.attachmentDetails())
            cell.removeButton.alpha = 0
            defaultCell = cell
        } else if let linkAttachment = self.feedData?.linkAttachment,
                    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCollectionViewCell.cellIdentifier, for: indexPath) as? LinkCollectionViewCell {
            cell.setupLinkCell(linkAttachment.title, description: linkAttachment.description, link: linkAttachment.url, linkThumbnailUrl: linkAttachment.linkThumbnailUrl)
            cell.removeButton.alpha = 0
            defaultCell = cell
        }
        return defaultCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.feedData?.postAttachmentType() ?? .unknown {
        case .link, .image, .video:
            self.collectionSuperViewHeightConstraint.constant = UIScreen.main.bounds.width
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        case .document:
            let count = self.feedData?.attachments?.count ?? 0
            self.collectionSuperViewHeightConstraint.constant = CGFloat(90 * (count > 3 ? 3 : count))
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x  / self.frame.width)    }
    
}

class LMTapGesture: UITapGestureRecognizer {
    var index = Int()
}
