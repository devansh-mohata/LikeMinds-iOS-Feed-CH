//
//  Array+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 16/05/23.
//

import Foundation

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
