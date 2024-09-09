
import Foundation
import UIKit

public class LMBranding {
    
    public static let shared = LMBranding()

    var buttonColor : UIColor = UIColor(hexString: "#007AFF")
    var headerColor : UIColor = UIColor(white: 249.0 / 255.0, alpha: 1)
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
    var buttonColor : UIColor = UIColor(hexString: "#007AFF")
    var headerColor : UIColor = UIColor(white: 249.0 / 255.0, alpha: 1)
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
