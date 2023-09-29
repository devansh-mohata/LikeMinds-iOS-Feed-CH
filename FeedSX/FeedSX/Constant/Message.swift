//
//  Message.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 23/05/23.
//

import Foundation

public struct MessageConstant {
    private init() {}
    static let restrictToCreatePost = "You do not have permission to create a post."
    static let restrictToCommentOnPost = "You do not have permission to comment."
    static let postingInProgress = "A post is already uploading!"
    static let nofiticationFeedDataNotFound = "Oops! You don't have any notification yet."
    static let articalMinimumBodyCharError = "Please provide minimum 200 characters in article body!"
    static let articalMinimumBodyChars = " Write something here (min. 200 char)"
    static let maxVideoError = "The file you have selected is too large.\nThe max. size should be \(ConstantValue.maxVideoUploadSizeInMB)MB"
    static let maxPDFError = "The file you have selected is too large.\nThe max. size should be \(ConstantValue.maxPDFUploadSizeInMB)MB"
    static let aritcleCoverPhotoRatioError = "Please select 16:9 size cover photo"
    static let fileSizeTooBig = "File size too big"
}
