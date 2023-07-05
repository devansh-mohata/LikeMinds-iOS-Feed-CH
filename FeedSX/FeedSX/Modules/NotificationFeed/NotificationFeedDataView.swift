//
//  NotificationFeedDataView.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 15/06/23.
//

import Foundation
import LikeMindsFeed

class NotificationFeedDataView {
    let activity: Activity
    let user: User?
    var isRead: Bool
    
    init(activity: Activity, user: User?) {
        self.activity = activity
        self.user = user
        self.isRead = activity.isRead ?? false
    }
    
    func activityText() -> NSAttributedString {
        guard var text = self.activity.activityText else { return NSAttributedString() }
        if let r1 = text.range(of: "\""),
           let r2 = text.range(of: "\"", range: r1.upperBound..<text.endIndex) {
            let stringBetweenQuotes = text.substring(with: r1.upperBound..<r2.lowerBound)
            let parsedText = TaggedRouteParser.shared.getTaggedParsedAttributedString(with: stringBetweenQuotes, andPrefix: "", forTextView: false, withTextColor: ColorConstant.likeTextColor, withHilightFont: LMBranding.shared.font(16, .regular), withHighlightedColor: ColorConstant.likeTextColor, isShowLink: false)
            text = text.replacingOccurrences(of: stringBetweenQuotes, with: parsedText?.string ?? "")
        }
        return TaggedRouteParser.shared.getTaggedParsedAttributedString(with: text, andPrefix: "", forTextView: false, withTextColor: ColorConstant.likeTextColor, withHilightFont: LMBranding.shared.font(16, .medium), withHighlightedColor: ColorConstant.textBlackColor, isShowLink: false) ?? NSAttributedString()
    }
}
