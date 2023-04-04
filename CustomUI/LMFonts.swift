//
//  LMFonts.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 27/03/23.
//

import Foundation

/// Enum for type of fonts (regular, medium, bold etc)
enum LMFontType: Int {
    case regular
    case medium
    case bold
}

/// Fonts Data Model with font's type name
public class LMFonts {
    /// regular font type
    var regular: String
    /// medium font type
    var medium: String
    /// bold font type
    var bold: String
    
    /// initialize method with font's type name params
    public init(regular: String, medium: String, bold: String) {
        self.regular = regular
        self.medium = medium
        self.bold = bold
    }
}
