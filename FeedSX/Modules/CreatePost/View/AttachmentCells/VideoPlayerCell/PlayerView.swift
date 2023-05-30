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

class PlayerView: UIView {
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
}
