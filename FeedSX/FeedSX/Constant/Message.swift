//
//  Message.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 23/05/23.
//

import Foundation

public struct StringConstant {
    private init() {}
    static let nofiticationFeedDataNotFound = "Oops! You don't have any notification yet."
    static let articalMinimumBodyCharError = "Please provide minimum 200 characters in article body!"
    static let articalMinimumBodyChars = " Write something here (min. 200 char)"
    static let maxVideoError = "The file you have selected is too large.\nThe max. size should be \(ConstantValue.maxVideoUploadSizeInMB)MB"
    static let maxPDFError = "The file you have selected is too large.\nThe max. size should be \(ConstantValue.maxPDFUploadSizeInMB)MB"
    static let aritcleCoverPhotoRatioError = "Please select 16:9 size cover photo"
    static let fileSizeTooBig = "File size too big"
    
    static var restrictToCreatePost: String {
        String(format: "You do not have permission to create a %@.", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .allSmallSingular))
    }
    static let restrictToCommentOnPost = "You do not have permission to comment."
    static var postingInProgress: String {  String(format: "A %@ is already uploading!", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .allSmallSingular))
    }
    
    struct PostDetail {
        private init() {}
        static var screenTitle: String { String(format: "%@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .firstLetterCapitalSingular))
        }
    }
    
    struct EditPost {
        private init() {}
        static var screenTitle: String { String(format: "Edit %@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .firstLetterCapitalSingular))
        }
    }
    struct HomeFeed {
        private init() {}
        static var unpinThisPost: String {
            String(format: "Unpin This %@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .firstLetterCapitalSingular))
        }
        static var pinThisPost: String {
            String(format: "Pin This %@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .firstLetterCapitalSingular))
        }
        static var creatingResource: String {
            String(format: "Creating %@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .firstLetterCapitalSingular))
        }
        static var newPost: String {
            String(format: "NEW %@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .allCapitalSingular))
        }
    }
    
    struct CreatePost {
        private init() {}
        static var screenTitle: String {
            String(format: "Create a %@", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .allSmallSingular))
        }
    }
    
    struct ReportPost {
        private init() {}
        static var reportSubtitle: String {
            String(format: "You would be able to report this %@ after selecting a problem.", pluralizeOrCapitalize(to: LocalPrefrerences.getPostVariable, withAction: .allSmallSingular))
        }
    }
}

enum WordAction: Int {
    case firstLetterCapitalSingular
    case allCapitalSingular
    case allSmallSingular
    case firstLetterCapitalPlural
    case allCapitalPlural
    case allSmallPlural
}

func pluralizeOrCapitalize(to value: String, withAction action: WordAction) -> String {
    switch action {
    case .firstLetterCapitalSingular:
        return value.capitalized
    case .allCapitalSingular:
        return value.uppercased()
    case .allSmallSingular:
        return value.lowercased()
    case .firstLetterCapitalPlural:
        return value.pluralize().capitalized
    case .allCapitalPlural:
        return value.pluralize().uppercased()
    case .allSmallPlural:
        return value.pluralize().lowercased()
    }
}
