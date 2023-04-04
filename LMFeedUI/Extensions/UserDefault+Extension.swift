//
//  UserDefault+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 30/03/23.
//

import Foundation
import LMFeed

public class LocalPrefrerences {
    
    public static func saveObject<T: Encodable>(_ object: T, forKey: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: forKey)
        }
    }
    
    public static func getUserData() -> User? {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "UserData") as? Data {
            do {
                let decoder = JSONDecoder()
                let saved = try decoder.decode(User.self, from: savedData)
                return saved
            } catch let error {
                print("Error getting cart from defaults \(error)")
            }
        }
        return nil
    }
    
}
