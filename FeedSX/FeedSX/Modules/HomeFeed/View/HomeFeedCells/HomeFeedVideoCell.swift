//
//  HomeFeedVideoCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/08/23.
//

import UIKit
import AVFoundation


class HomeFeedVideoCell: UITableViewCell {
    
    static let nibName: String = "HomeFeedVideoCell"
    static let bundle = Bundle(for: HomeFeedVideoCell.self)
    
    // The PlayerView
    var playerView: PlayerView = {
        var player = PlayerView()
        player.backgroundColor = .black
        return player
    }()
    var avPlayerItem: AVPlayerItem?
    var avQueuePlayer: AVQueuePlayer?
    var avPlayerlayerLooper: AVPlayerLooper?
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var actionsSectionView: UIView!
    @IBOutlet weak var playButton: UIButton!
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
        setupVideoPlayerView()
        setupProfileSectionHeader()
        setupActionSectionFooter()
        
        self.playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupVideoPlayerView() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        // TODO:- Need to handle activity indicator
        containerView.addSubview(activityIndicator)
        containerView.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playerView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.activityIndicator.hidesWhenStopped = true
        containerView.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.stopAnimating()
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
//        self.delegate = delegate
        self.setupVideoData(url: feedDataView.imageVideos?.first?.url ?? "")
        profileSectionHeader.setupProfileSectionData(feedDataView, delegate: delegate)
        actionFooterSectionView.setupActionFooterSectionData(feedDataView, delegate: delegate)
        self.layoutIfNeeded()
    }
    
    func pauseVideo() {
        playButton.isHidden = false
        playerView.player?.pause()
    }
    
    @objc func playVideo() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        self.activityIndicator.startAnimating()
        if playerView.player != nil {
            playerView.player?.playImmediately(atRate: 1)
            playerView.player?.play()
            playButton.isHidden = true
            //TODO:- Need to handle loading indicator, as of now we added inital for 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    func stopVideo() {
    }
    
    func setupVideoData(url: String) {
        guard let _ = URL(string: url) else {
            print("Not opened")
            return
        }
        createFanPlayer(videoName: url)
    }
    
    func createFanPlayer(videoName: String)  {
        guard let pathURL = URL(string: videoName) else {
            print("Not opened")
            return
        }
        
        avQueuePlayer = AVQueuePlayer()
        avPlayerItem = AVPlayerItem(url: pathURL)
        avPlayerlayerLooper = AVPlayerLooper(player: avQueuePlayer!, templateItem: avPlayerItem!)
        playerView.player = avQueuePlayer
    }
    
}
