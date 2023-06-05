//
//  DataDetector.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 10/04/23.
//

import Foundation

// MARK: DataDetector

class DataDetector {
    
    private class func _find(all type: NSTextCheckingResult.CheckingType,
                             in string: String, iterationClosure: (String) -> Bool) {
        guard let detector = try? NSDataDetector(types: type.rawValue) else { return }
        let range = NSRange(string.startIndex ..< string.endIndex, in: string)
        let matches = detector.matches(in: string, options: [], range: range)
    loop: for match in matches {
        for i in 0 ..< match.numberOfRanges {
            let nsrange = match.range(at: i)
            let startIndex = string.index(string.startIndex, offsetBy: nsrange.lowerBound)
            let endIndex = string.index(string.startIndex, offsetBy: nsrange.upperBound)
            let range = startIndex..<endIndex
            guard iterationClosure(String(string[range])) else { break loop }
        }
    }
    }
    
    class func find(all type: NSTextCheckingResult.CheckingType, in string: String) -> [String] {
        var results = [String]()
        _find(all: type, in: string) {
            results.append($0)
            return true
        }
        return results
    }
    
    class func first(type: NSTextCheckingResult.CheckingType, in string: String) -> String? {
        var result: String?
        _find(all: type, in: string) {
            result = $0
            return false
        }
        return result
    }
}
