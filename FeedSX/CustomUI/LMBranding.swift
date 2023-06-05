
import Foundation
import UIKit

public class LMBranding {
    
    public static let shared = LMBranding()

    var buttonColor : UIColor = UIColor(hexString: "#5046E5")
    var headerColor : UIColor = UIColor(hexString: "#5046E5")
    var textLinkColor : UIColor = UIColor(hexString: "#007AFF")
    
    let key = "BrandingModel"
    /// Custom fonts data
    private var fonts: LMFonts?
    
    private init(){}
    
    
    public func setBranding(_ bradingRequest: SetBrandingRequest) {
        self.buttonColor = bradingRequest.buttonColor
        self.headerColor = bradingRequest.headerColor
        self.textLinkColor = bradingRequest.textLinkColor
        self.fonts = bradingRequest.fonts
    }
    
    /// To set new costom fonts
    func invalidateFonts(_ fonts: LMFonts?) {
        self.fonts = fonts
    }
    
    /// To get fonts
    func getFonts() -> LMFonts? {
        return self.fonts
    }
    
    /// Method used for to get font with provided size and font type
    func font(_ fontSize: CGFloat, _ fontType: LMFontType) -> UIFont {
        let defaultFont = defaultFont(with: fontSize, type: fontType)
        guard let font = fonts else {
            return defaultFont
        }
        switch fontType {
        case .regular:
            return UIFont(name: font.regular, size: fontSize) ?? defaultFont
        case .medium:
            return UIFont(name: font.medium, size: fontSize) ?? defaultFont
        case .bold:
            return UIFont(name: font.bold, size: fontSize) ?? defaultFont
        }
    }
    
    /// This method provides default font
    private func defaultFont(with fontSize: CGFloat, type: LMFontType) -> UIFont {
        switch type {
        case .regular:
            return UIFont.systemFont(ofSize: fontSize, weight: .regular)
        case .medium:
            return UIFont.systemFont(ofSize: fontSize, weight: .medium)
        case .bold:
            return UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
    }
}


public class SetBrandingRequest {
    var buttonColor : UIColor = UIColor(hexString: "#5046E5")
    var headerColor : UIColor = UIColor(hexString: "#FFFFFF")
    var textLinkColor : UIColor = UIColor(hexString: "#007AFF")
    var fonts: LMFonts = LMFonts(regular: "Roboto",
                                 medium: "Roboto-Medium",
                                 bold: "Roboto-Bold")
    public init() {}
    
    public func buttonColor(_ color: UIColor) -> SetBrandingRequest {
        self.buttonColor = color
        return self
    }
    
    public func headerColor(_ color: UIColor) -> SetBrandingRequest {
        self.headerColor = color
        return self
    }
    
    public func textLinkColor(_ color: UIColor) -> SetBrandingRequest {
        self.textLinkColor = color
        return self
    }
    
    public func fonts(_ fonts: LMFonts) -> SetBrandingRequest {
        self.fonts = fonts
        return self
    }
}


/*
struct Branding: Decodable, Encodable {
    var basic: Basic?
    var advance: Advance?
    
    enum CodingKeys: String, CodingKey {
        case basic = "basic"
        case advance = "advanced"
    }
}

struct Basic: Decodable, Encodable {
    var basicColor: String?
    enum CodingKeys: String, CodingKey {
        case basicColor = "primary_colour"
    }
}

struct Advance: Decodable, Encodable {
    var headerColor: String?
    var buttonIconsColour: String?
    var textLinksColour: String?
    
    enum CodingKeys: String, CodingKey {
        case headerColor = "header_colour"
        case buttonIconsColour = "buttons_icons_colour"
        case textLinksColour = "text_links_colour"
    }
}

*/
