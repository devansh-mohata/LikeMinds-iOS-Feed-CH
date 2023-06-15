//
//  TaggingViewDataSource.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 08/06/23.
//

import Foundation

protocol TaggingViewDataSource: AnyObject {
    func tagging(_ tagging: TaggingView, didChangedTagableList tagableList: [String])
    func tagging(_ tagging: TaggingView, didChangedTaggedList taggedList: [TaggedUser])
    func tagging(_ tagging: TaggingView, searchForTagableList fromText: String)
}

extension TaggingViewDataSource {
    func tagging(_ tagging: TaggingView, didChangedTagableList tagableList: [String]) {return}
    func tagging(_ tagging: TaggingView, didChangedTaggedList taggedList: [TaggedUser]) {return}
    func tagging(_ tagging: TaggingView, searchForTagableList fromText: String) {}
}
