//
//  VideoCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 08/04/23.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "VideoCollectionViewCell"
    
    // The PlayerView
    var playerView: PlayerView = {
        var player = PlayerView()
        player.backgroundColor = .black
        return player
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        button.tintColor = .darkGray
        button.setPreferredSymbolConfiguration(.init(pointSize: 20, weight: .light, scale: .large), forImageIn: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setSizeConstraint(width: 30, height: 30)
        return button
    }()
    
    weak var delegate: AttachmentCollectionViewCellDelegate?
    // The AVPlayer
    var videoPlayer: AVPlayer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // add the imageview to the UICollectionView
        addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(removeButton)
        removeButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        removeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        bringSubviewToFront(self.removeButton)
    }
    
    func pauseVideo() {
        playerView.player?.pause()
    }
    
    func playVideo() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        playerView.player?.playImmediately(atRate: 1)
        playerView.player?.play()
    }
    
    func stopVideo() {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVideoData(url: String) {
        guard let urL = URL(string: url) else {
            print("Not opened")
            return
        }
        // set the video player with the path
        videoPlayer = AVPlayer(url: urL)
        // play the video now!
//        videoPlayer?.playImmediately(atRate: 1)
        videoPlayer?.isMuted = false
        // setup the AVPlayer as the player
        playerView.player = videoPlayer
    }
    
    // This is the function to setup the CollectionViewCell
    func setupCell(image: String) {
        // set the appropriate image, if we can form a UIImage
        //        if let image : UIImage = UIImage(named: image) {
        //            hotelImageView.image = image
        //        }
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }
}
