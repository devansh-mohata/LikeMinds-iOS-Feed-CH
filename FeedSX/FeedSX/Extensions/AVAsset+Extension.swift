//
//  AVAsset+Extension.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 20/09/23.
//

import Foundation
import AVFoundation

extension AVAsset {
    
    func videoDuration() -> Int {
        let duration = self.duration
        return Int(CMTimeGetSeconds(duration))
    }
    
    static func videoSizeInKB(url: URL) -> Int {
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.relativePath) {
            var videoSize = attr[.size] as? Int
            return (videoSize ?? 0)/1000
        }
        return 0
    }
    
}
