//
//  YoutubeViewController.swift
//  FeedSX
//
//  Created by Devansh Mohata on 12/10/23.
//

import UIKit
import youtube_ios_player_helper

public class YoutubeViewController: UIViewController {
    @IBOutlet private weak var youtubePlayerView: YTPlayerView!
    @IBOutlet private weak var youtubeIndicator: UIActivityIndicatorView!
    
    private let videoID: String
    
    private let ytPlayerVars = ["rel" : 0,
                                "showinfo": 0,
                                "disablekb": 1,
                                "playsinline" : 1,
                                "fs": 0,
                                "controls": 1]
    
    init(videoID: String) {
        self.videoID = videoID
        super.init(nibName: "YoutubeViewController", bundle: Bundle.lmBundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Meant to be used from \(#function)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        youtubeIndicator.color = .white
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerTapped))
        view.addGestureRecognizer(panGestureRecognizer)
        view.isUserInteractionEnabled = true
        
        youtubePlayerView.delegate = self
        youtubePlayerView.load(withVideoId: videoID, playerVars: ytPlayerVars)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc
    private func panGestureRecognizerTapped(sender: UIPanGestureRecognizer) {
        
        var trans = CATransitionSubtype.fromLeft
        
        let velocity = sender.velocity(in: view)
        
        trans = velocity.x > 0 ? .fromLeft : .fromRight
        trans = velocity.y > 0 ? .fromBottom : .fromTop
        
        let transition = CATransition()
        transition.duration = 1
        transition.type = .fade
        transition.subtype = trans
        
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popViewController(animated: false)
    }
}

extension YoutubeViewController: YTPlayerViewDelegate {
    public func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        youtubeIndicator.stopAnimating()
        playerView.playVideo()
    }
    
    public func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        .clear
    }
}
