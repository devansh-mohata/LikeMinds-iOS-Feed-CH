//
//  URL+Extension.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 26/09/23.
//

import Foundation

extension URL {
    
    static func url(string: String) -> URL? {
        guard let url = URL(string: string) else {
            return URL(string: string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        }
        return url
    }
    
    func domainUrl() -> String? {
        return "https://" + (self.host ?? "")
    }
}
