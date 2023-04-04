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
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var imageVideoCollectionView: UICollectionView!
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
    
    let postCaptionView: PostCaptionView = {
        let captionView = PostCaptionView()
        captionView.translatesAutoresizingMaskIntoConstraints = false
        return captionView
    }()
    
    var feedData: HomeFeedDataView?
    
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
    
    func setupFeedCell(_ feedDataView: HomeFeedDataView, withDelegate delegate: HomeFeedTableViewCellDelegate?) {
        self.feedData = feedDataView
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        setupCaption()
        imageVideoCollectionView.reloadData()
    }
    
    func setupImageCollectionView() {
        let nib = UINib(nibName: "ImageVideoCollectionViewCell", bundle: Bundle(for: ImageVideoCollectionViewCell.self))
        self.imageVideoCollectionView.register(nib, forCellWithReuseIdentifier: ImageVideoCollectionViewCell.cellIdentifier)
        imageVideoCollectionView.dataSource = self
        imageVideoCollectionView.delegate = self
    }
    
    private func setupCaption(){
        self.captionLabel.text = self.feedData?.caption
    }
    
}

extension HomeFeedImageVideoTableViewCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedData?.imageVideos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImageVideoCollectionViewCell.cellIdentifier, for: indexPath) as? ImageVideoCollectionViewCell,
              let imageVideoItem = self.feedData?.imageVideos?[indexPath.row] else { return UICollectionViewCell() }
        cell.setupImageVideoView(imageVideoItem)
        cell.contentView.backgroundColor = .green
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        pageControl.setCurrentPage(at: Int(scrollView.contentOffset.x  / self.frame.width))
    }
}

class LMTapGesture: UITapGestureRecognizer {
    var index = Int()
}
