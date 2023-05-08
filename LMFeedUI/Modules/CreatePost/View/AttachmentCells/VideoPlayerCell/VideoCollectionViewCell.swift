//
//  VideoCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 08/04/23.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell2: UICollectionViewCell {
    
    static let cellIdentifier = "VideoCollectionViewCell"
    static let nibName = "VideoCollectionViewCell"
    
    @IBOutlet weak var videoPlayerSuperView: UIView!
    @IBOutlet weak var dummyLabel: UILabel!
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
    }
    
    func setupVideoPlayerItem(_ url: String) {
        guard let uRL = URL(string: url) else {
            return
        }
        self.videoPlayerItem = AVPlayerItem.init(url: uRL)
    }
    
    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none
        if UIScreen.main.bounds.width == 375 {
            let widthRequired = self.frame.size.width - 20
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        } else if UIScreen.main.bounds.width == 320 {
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
            
        } else {
            let widthRequired = self.frame.size.width
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        }
//        avPlayerLayer?.frame = self.videoPlayerSuperView.bounds
        self.backgroundColor = .clear
        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero)
    }
    
}

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
    
    func stopVideo() {
        playerView.player?.pause()
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
//        videoPlayer = AVPlayer(url: urL)
        // play the video now!
        videoPlayer?.playImmediately(atRate: 1)
        videoPlayer?.isMuted = true
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
