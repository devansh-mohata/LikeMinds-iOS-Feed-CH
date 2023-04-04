//
//  ImageVideoCollectionTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 31/03/23.
//

import UIKit

/*
 class ImageVideoCollectionTableViewCell: HomeFeedTableViewCell {
 
 static let cellIdentifier = "ImageVideoCollectionTableViewCell"
 let imageVideoCollectionView: UICollectionView = {
 let flowlayout = UICollectionViewFlowLayout()
 flowlayout.scrollDirection = .horizontal
 return UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
 }()
 
 override func awakeFromNib() {
 super.awakeFromNib()
 setupImageCollectionView()
 }
 
 override func setSelected(_ selected: Bool, animated: Bool) {
 super.setSelected(selected, animated: animated)
 
 }
 
 func setupImageCollectionView() {
 
 imageVideoCollectionView.dataSource = self
 imageVideoCollectionView.delegate = self
 self.containerView.addSubview(imageVideoCollectionView)
 self.imageVideoCollectionView.register(ImageVideoCollectionViewCell.self, forCellWithReuseIdentifier: ImageVideoCollectionViewCell.cellIdentifier)
 imageVideoCollectionView.translatesAutoresizingMaskIntoConstraints = false
 imageVideoCollectionView.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
 imageVideoCollectionView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
 imageVideoCollectionView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor).isActive = true
 imageVideoCollectionView.rightAnchor.constraint(equalTo: self.containerView.rightAnchor).isActive = true
 }
 
 func setupImageViewFeedCell(_ feedDataView: HomeFeedDataView) {
 self.setupFeedCell(feedDataView)
 imageVideoCollectionView.reloadData()
 }
 
 }
 
 extension ImageVideoCollectionTableViewCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return self.feedData?.imageVideos?.count ?? 0
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImageVideoCollectionViewCell.cellIdentifier, for: indexPath) as? ImageVideoCollectionViewCell,
 let imageVideoItem = self.feedData?.imageVideos?[indexPath.row] else { return UICollectionViewCell() }
 cell.setupImageVideoView(imageVideoItem)
 return cell
 }
 
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
 }
 
 func scrollViewDidScroll(_ scrollView: UIScrollView) {
 //        pageControl.setCurrentPage(at: Int(scrollView.contentOffset.x  / self.frame.width))
 }
 }
 */
