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
    var avPlayerItem: AVPlayerItem?
    var avQueuePlayer: AVQueuePlayer?
    var avPlayerlayerLooper: AVPlayerLooper?
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
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
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
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
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.activityIndicator.hidesWhenStopped = true
        bringSubviewToFront(self.activityIndicator)
    }
    
    func pauseVideo() {
        playerView.player?.pause()
    }
    
    func playVideo() {
//        self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        if playerView.player != nil {
            playerView.player?.playImmediately(atRate: 1)
            playerView.player?.play()
//            playerView.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        }
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
        createFanPlayer(videoName: url)
        return
        // set the video player with the path
//        videoPlayer = AVPlayer(url: urL)
        // play the video now!
//        videoPlayer?.playImmediately(atRate: 1)
//        videoPlayer?.isMuted = false
        // setup the AVPlayer as the player
        
    }
    
    func createFanPlayer(videoName: String)  {
        guard let pathURL = URL(string: videoName) else {
            print("Not opened")
            return
        }
        
//        pauseVideo()
        
        avQueuePlayer = AVQueuePlayer()
        avPlayerItem = AVPlayerItem(url: pathURL)
        avPlayerlayerLooper = AVPlayerLooper(player: avQueuePlayer!, templateItem: avPlayerItem!)
        
//        playerView.frame = fanVideoShowView.bounds
//        playerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        fanVideoShowView.layer.insertSublayer(fanPlayerLayer, at: 1)
        
        playerView.player = avQueuePlayer
//        sharedPlayView = playerView
//        if playerView.player != nil {
//            playerView.player?.play()
//            playerView.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
//        }
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
    
    deinit {
        print("videocell removed---")
        if playerView.player != nil {
//            playerView.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            if #available(iOS 10.0, *) {
                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                if newStatus != oldStatus {
                    DispatchQueue.main.async {[weak self] in
                        if newStatus == .playing || newStatus == .paused {
                            self?.activityIndicator.stopAnimating()
                        } else {
                            self?.activityIndicator.startAnimating()
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
