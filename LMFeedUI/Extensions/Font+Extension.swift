//
//  Font+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 27/03/23.
//

import Foundation
import UIKit

extension UIFont {
    func brandingFont() -> UIFont {
        let fontName = self.fontName
        let fontSize = self.pointSize
        if fontName.lowercased().contains("-bold") {
            return LMBranding.shared.font(fontSize, .bold)
        } else if fontName.lowercased().contains("-regular") {
            return LMBranding.shared.font(fontSize, .regular)
        } else {
            return LMBranding.shared.font(fontSize, .medium)
        }
    }
}
