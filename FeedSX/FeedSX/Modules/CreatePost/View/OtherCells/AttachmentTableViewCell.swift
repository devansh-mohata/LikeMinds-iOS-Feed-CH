//
//  AttachmentTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 01/05/23.
//

import UIKit

class AttachmentTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "AttachmentTableViewCell"
    var imageAndVideoAttachments: [PostFeedDataView.ImageVideo] = []
    var documentAttachments: [PostFeedDataView.Attachment] = []
    var linkAttatchment: PostFeedDataView.LinkAttachment?
    var currentSelectedUploadeType: CreatePostViewModel.AttachmentUploadType = .unknown
    
    private let collectionView: UICollectionView = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        self.contentView.addSubview(collectionView)
        collectionView.addConstraints(equalToView: self.contentView)
        self.collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.cellIdentifier)
        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
        self.collectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)
        
        let linkNib = UINib(nibName: "LinkCollectionViewCell", bundle: Bundle(for: LinkCollectionViewCell.self))
        self.collectionView.register(linkNib, forCellWithReuseIdentifier: LinkCollectionViewCell.cellIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
//        self.pageControl?.currentPageIndicatorTintColor = LMBranding.shared.buttonColor
    }
    
    func setupImageVideoCell(arr: [PostFeedDataView.ImageVideo], type: CreatePostViewModel.AttachmentUploadType) {
        self.imageAndVideoAttachments = arr
        self.currentSelectedUploadeType = type
        collectionView.reloadData()
    }
    
    func setupDocumentCell(arr: [PostFeedDataView.Attachment], type: CreatePostViewModel.AttachmentUploadType) {
        self.documentAttachments = arr
        self.currentSelectedUploadeType = type
        collectionView.reloadData()
    }
    
    func setupLinkCell(link: PostFeedDataView.LinkAttachment, type: CreatePostViewModel.AttachmentUploadType) {
        self.linkAttatchment = link
        self.currentSelectedUploadeType = type
        collectionView.reloadData()
    }
}

extension AttachmentTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.currentSelectedUploadeType {
        case .video, .image:
            return imageAndVideoAttachments.count
        case .document:
            return documentAttachments.count
        case .link:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
        switch self.currentSelectedUploadeType {
        case .link:
            if let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCollectionViewCell.cellIdentifier, for: indexPath) as? LinkCollectionViewCell {
                let linkAttachment = self.linkAttatchment
                cell.setupLinkCell(linkAttachment?.title, description: linkAttachment?.description, link: linkAttachment?.url, linkThumbnailUrl: linkAttachment?.linkThumbnailUrl)
                cell.delegate = self
                defaultCell = cell
            }
        case .video, .image:
            let item = self.imageAndVideoAttachments[indexPath.row]
            if  item.fileType == .image,
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.cellIdentifier, for: indexPath) as? ImageCollectionViewCell {
                cell.setupImageVideoView(self.imageAndVideoAttachments[indexPath.row].url)
                cell.delegate = self
                defaultCell = cell
            } else if item.fileType == .video,
                      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.cellIdentifier, for: indexPath) as? VideoCollectionViewCell,
                      let url = item.url {
                cell.setupVideoData(url: url)
                
                defaultCell = cell
            }
            
        case .document:
            let item = self.documentAttachments[indexPath.row]
            if  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
                cell.setupDocumentCell(item.attachmentName(), documentDetails: item.attachmentDetails())
                cell.delegate = self
                defaultCell = cell
            }
        default:
            break
        }
        return defaultCell
    }
}

extension AttachmentTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension AttachmentTableViewCell: AttachmentCollectionViewCellDelegate {
    
    func removeAttachment(_ cell: UICollectionViewCell) {
        print("remove data")
    }
}
