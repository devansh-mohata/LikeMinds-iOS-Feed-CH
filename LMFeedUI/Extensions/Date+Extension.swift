//
//  Date+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 29/03/23.
//

import Foundation

extension Date {
    
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let ago = "ago"
        if secondsAgo == 0 {
            return "Just now"
        }
//        if secondsAgo < minute {
//            if secondsAgo == 1 {
//                return "\(secondsAgo) second"
//            } else {
//                return "\(secondsAgo) seconds"
//            }
//        } else
        if secondsAgo < hour {
            if secondsAgo / minute == 1 {
                return "\(secondsAgo / minute) minute"
            } else {
                return "\(secondsAgo / minute) minutes"
            }
        } else if secondsAgo < day {
            if secondsAgo / hour == 1 {
                return "\(secondsAgo / hour) hour"
            } else {
                return "\(secondsAgo / hour) hours"
            }
        } else if secondsAgo < week {
            if secondsAgo / day == 1 {
                return "\(secondsAgo / day) day"
            } else {
                return "\(secondsAgo / day) days"
            }
        }
        
        if secondsAgo / week == 1 {
            return "\(secondsAgo / week) week ago"
        } else {
            return "\(secondsAgo / week) weeks ago"
        }
    }
    
    func timeAgoDisplayShort() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo == 0 {
            return "Just now"
        }
        if secondsAgo < minute {
            return "\(secondsAgo)s"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute)m"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour)h"
        } else if secondsAgo < week {
            return "\(secondsAgo / day)d"
        }
        
        return "\(secondsAgo / week)wk"
    }
}
