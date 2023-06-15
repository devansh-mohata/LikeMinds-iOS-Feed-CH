//
//  TaggedRouteParser.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 12/04/23.
//

import Foundation
import UIKit
import LikeMindsFeed

class TaggedRouteParser {
    
    static let shared = TaggedRouteParser()
    private init(){}
    
    struct NameWithRoute {
        var name: String
        var route: String
        
        func getIdFromRoute() -> String {
            self.route.components(separatedBy: "/").last ?? ""
        }
    }
    
    private func replaceRouteToName(with answer: String, andPrefix prefix: String?, forTextView: Bool, withTextColor textColor: UIColor = .black, withFont font:UIFont? = nil, withHighlightedColor highlightedColour: UIColor, isShowLink showLink: Bool) -> NSMutableAttributedString {
        let prefixString = prefix ?? ""
        let nameWithRoutes = getUserNames(in: answer)
        let textFont = font ?? LMBranding.shared.font(forTextView ? 16 : 13, .regular)
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
    
    private func replaceRouteToNameWithTaggedUsers(with answer: String, andPrefix prefix: String?, forTextView: Bool, withTextColor textColor: UIColor = .black, withFont font:UIFont? = nil, withHighlightedColor highlightedColour: UIColor, isShowLink showLink: Bool) -> (NSMutableAttributedString, [TaggedUser]) {
        var taggedUsers = [TaggedUser]()
        let prefixString = prefix ?? ""
        let nameWithRoutes = getUserNames(in: answer)
        let textFont = font ?? LMBranding.shared.font(forTextView ? 16 : 13, .regular)
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
                var nameRange = NSRange(range, in: attrString.string)
                // Replace content in range with the new content
                attrString.replaceCharacters(in: nameRange, with: newAttributedString)
                nameRange.length = newAttributedString.length
//                nameRange.location = nameRange.location - newAttributedString.length
                taggedUsers.append(TaggedUser(TaggingUser(name: nameWithRoute.name, id: nameWithRoute.getIdFromRoute()), range: nameRange))
            }
        }
        return (attrString, taggedUsers)
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
    
    @objc func getTaggedParsedAttributedString(with answer: String?, andPrefix prefix: String? = "@", forTextView: Bool, withTextColor textColor: UIColor = .black, withFont font:UIFont? = LMBranding.shared.font(16, .regular), withHighlightedColor highlightedColour: UIColor = LMBranding.shared.textLinkColor, isShowLink showLink: Bool = true) -> NSMutableAttributedString?  {
        return replaceRouteToName(with: answer ?? "", andPrefix: prefix, forTextView: forTextView, withTextColor: textColor, withFont: font, withHighlightedColor: highlightedColour, isShowLink: showLink)
    }
    
    func getTaggedParsedAttributedStringForEditText(with answer: String?, andPrefix prefix: String? = "@", forTextView: Bool, withTextColor textColor: UIColor = .black, withFont font:UIFont? = LMBranding.shared.font(16, .regular), withHighlightedColor highlightedColour: UIColor = LMBranding.shared.textLinkColor, isShowLink showLink: Bool = true) -> (NSMutableAttributedString, [TaggedUser])  {
        
        return replaceRouteToNameWithTaggedUsers(with: answer ?? "", andPrefix: prefix, forTextView: forTextView, withTextColor: textColor, withFont: font, withHighlightedColor: highlightedColour, isShowLink: showLink)
    }
    
    func createTaggednames(with answer: String, member: User, attributedMessage: NSAttributedString?, textRange: NSRange? = nil)-> NSMutableAttributedString?  {
        let name = member.name ?? ""
        var textArray = answer.components(separatedBy: .whitespacesAndNewlines)//
        var text = textArray.last?.components(separatedBy: "@").last ?? ""
        text = "@\(text)"
        var subStringOfRange = answer
        if let range = textRange, let atRateRange =  answer.range(of: "@") {
            let n1 = NSRange(atRateRange, in: answer)
            if answer.count > range.location {
                let indexSubstring = answer.index(answer.startIndex, offsetBy: range.location)
                let inputString = answer.prefix(upTo: indexSubstring)
                subStringOfRange = String(inputString)
                let indexSubstring2 = inputString.index(inputString.endIndex, offsetBy: -(inputString.count - n1.location))
                let inputString2 = inputString.suffix(from: indexSubstring2)
                let seperatedStingsArray = inputString2.components(separatedBy: "@")
                text = "@" + (seperatedStingsArray.last ?? "")
            }
        }
        
        let initialAttributes = [
            NSAttributedString.Key.foregroundColor: LMBranding.shared.textLinkColor,
            NSAttributedString.Key.font: LMBranding.shared.font(16, .medium)
        ]
        var attrString: NSAttributedString? = nil
        attrString = NSAttributedString(string: "@\(name) ", attributes: initialAttributes as [NSAttributedString.Key : Any])
        
        let index = text.count
        let start = text.index(text.startIndex, offsetBy: 0)
        let end = text.index(text.endIndex, offsetBy: -index)
        let range = start..<end
        
        let existingString = (text.substring(with: range))
        let replacementText = NSMutableAttributedString(attributedString: NSAttributedString(string: text))
        if let attrString = attrString {
            replacementText.replaceCharacters(in: NSRange(location: 0, length: index), with: attrString)
        }
        if textArray.count > 0 {
            textArray[textArray.count - 1] = replacementText.string
        }
        
        var originalString: NSMutableAttributedString? = nil
        if let attributedText = attributedMessage {
            originalString = NSMutableAttributedString(attributedString: attributedText)
        }
        
        if originalString?.length ?? 0 > 0 {
            let subStringInRange: NSMutableAttributedString? = NSMutableAttributedString(string: subStringOfRange)
            if let range = subStringInRange?.mutableString.range(of: text ?? "", options: .backwards) {
                if range.location != NSNotFound
                {
                    originalString?.replaceCharacters(in: range, with: replacementText)
                }
            }
            return originalString
        } else {
            return replacementText
        }
    }
    
    func editAnswerTextWithTaggedList(text: String?, taggedUsers: [TaggedUser]) -> String  {
        let tagUsers = taggedUsers.sorted(by: { $0.range.location > $1.range.location})
        if var answerText = text, tagUsers.count > 0 {
            for member in tagUsers {
                if let memberName = member.user.name {
                    guard let range = answerText.range(from: member.range) else { continue }
                    answerText = answerText.replacingCharacters(in: range, with: "<<\(memberName)|route://member/\(member.user.id )>>")
                }
            }
            answerText = answerText.trimmedText()
            return answerText
        }
        return text?.trimmedText() ?? ""
    }
}
