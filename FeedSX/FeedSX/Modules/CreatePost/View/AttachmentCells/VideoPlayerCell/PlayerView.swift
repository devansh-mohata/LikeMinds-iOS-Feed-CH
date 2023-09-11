//
//  PlayerView.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 10/04/23.
//

import Foundation

import Foundation
import UIKit
import AVKit
import AVFoundation

var sharedPlayView: PlayerView?

class PlayerView: UIView {
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        
        return layer as! AVPlayerLayer
    }
    
//    var player: AVPlayer? {
//        get {
//            return playerLayer.player
//        }
//        
//        set {
//            playerLayer.player = newValue
//        }
//    }
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    var player: AVQueuePlayer? {
        get {
            return playerLayer.player as? AVQueuePlayer
        }
        
        set {
            playerLayer.player = newValue
        }
    }
}
