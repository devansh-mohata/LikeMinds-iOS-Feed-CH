//
//  TaggedRouteParser.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 12/04/23.
//

import Foundation
import UIKit

class TaggedRouteParser {
    
    static let shared = TaggedRouteParser()
    private init(){}
    
    struct NameWithRoute {
        var name: String
        var route: String
    }
    
    private func replaceRouteToName(with answer: String, andPrefix prefix: String?, forTextView: Bool, withTextColor textColor: UIColor = .black, withFont font:UIFont? = nil, withHighlightedColor highlightedColour: UIColor, isShowLink showLink: Bool) -> NSMutableAttributedString {
        let prefixString = prefix ?? ""
        let nameWithRoutes = getUserNames(in: answer)
        let textFont = font ?? LMBranding.shared.font(forTextView ? 15 : 13, .regular)
        let attrString = NSMutableAttributedString(string: answer, attributes: [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: textFont
        ])
        for nameWithRoute in nameWithRoutes {
            let routeName = nameWithRoute.name.replacingOccurrences(of: "<<", with: "")
            let routeString = "<<\(routeName)|\(nameWithRoute.route)>>"
            let replaceString = "\(prefixString)\(routeName)"
            let replaceAttributes = (showLink ? [
                NSAttributedString.Key.foregroundColor: highlightedColour,
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.link: nameWithRoute.route
            ] : [
                NSAttributedString.Key.foregroundColor: highlightedColour,
                NSAttributedString.Key.font: textFont
            ]) as [NSAttributedString.Key : Any]
            let newAttributedString = NSMutableAttributedString(string: replaceString, attributes: replaceAttributes)
            // Get range of text to replace
            while let range = attrString.string.range(of: routeString) {
                let nameRange = NSRange(range, in: attrString.string)
                // Replace content in range with the new content
                attrString.replaceCharacters(in: nameRange, with: newAttributedString)
            }
        }
        return attrString
    }
    
    private func getUserNames(in answer: String?) -> [NameWithRoute] {
        let text = answer ?? ""
        let charSet = CharacterSet(charactersIn: "<<>>")
        let routeStringArray = text.components(separatedBy: charSet).filter({$0.contains("|")})
        let userNameMatches = routeStringArray.map({$0})
        var nameWithRoutes:[NameWithRoute] = []
        for userNameWithRoute in userNameMatches {
            let splitedNameAndRoute = userNameWithRoute.split(separator: "|")
            guard splitedNameAndRoute.count == 2 else {continue}
            let nameWithRoute = NameWithRoute(name: String(splitedNameAndRoute.first!), route: String(splitedNameAndRoute.last!))
            nameWithRoutes.append(nameWithRoute)
        }
        return nameWithRoutes
    }
    
    @objc func getTaggedParsedAttributedString(with answer: String?, andPrefix prefix: String? = "@", forTextView: Bool, withTextColor textColor: UIColor = .black, withFont font:UIFont? = LMBranding.shared.font(15, .regular), withHighlightedColor highlightedColour: UIColor = LMBranding.shared.textLinkColor, isShowLink showLink: Bool = true) -> NSMutableAttributedString?  {
        return replaceRouteToName(with: answer ?? "", andPrefix: prefix, forTextView: forTextView, withTextColor: textColor, withFont: font, withHighlightedColor: highlightedColour, isShowLink: showLink)
    }
}
