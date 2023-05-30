//
//  UIImage+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 12/04/23.
//

import Foundation
import UIKit

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    static func generateLetterImage(name: String?, withBackgroundColor color: UIColor? = nil) -> UIImage? {
        guard let nm = name else {return nil}
        let nmArr = nm.components(separatedBy: " ")
        var letter: String = ""
        if nmArr.count > 1,
           let firstLetter = nmArr.first?.uppercased().first,
           let lastLetter = nmArr.last?.uppercased().first {
            letter = "\(firstLetter)\(lastLetter)"
        } else if let firstLetter = nmArr.first?.uppercased().first {
            letter = "\(firstLetter)"
        }
        guard !fileExist(letter: String(letter)) else { return getLetterImage(letter: String(letter))}
        
        let nameInitialLabel = UILabel()
        nameInitialLabel.frame.size = CGSize(width: 250, height: 250)
        nameInitialLabel.textColor = UIColor.white
        nameInitialLabel.font = UIFont.boldSystemFont(ofSize: 150)
        nameInitialLabel.text = String(letter)
        nameInitialLabel.textAlignment = NSTextAlignment.center
        nameInitialLabel.backgroundColor = color == nil ? pickColor(alphabet: letter.first ?? "A") : color
        //nameInitialLabel.layer.cornerRadius = 125
        nameInitialLabel.clipsToBounds = true
        var img: UIImage? = nil
        UIGraphicsBeginImageContext(nameInitialLabel.frame.size)
        nameInitialLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        saveImges(letter: String(letter), img: img?.pngData())
        return img
        
    }
    
    static func generateLetterImage(with name: String?) -> UIImage? {
        return UIImage.generateLetterImage(name: name)
    }
    
    private static func pickColor(alphabet: Character) -> UIColor {
        let alphabetColors = [0x5A8770, 0xB2B7BB, 0x6FA9AB, 0xF5AF29, 0x0088B9, 0xF18636, 0xD93A37, 0xA6B12E, 0x5C9BBC, 0xF5888D, 0x9A89B5, 0x407887, 0x9A89B5, 0x5A8770, 0xD33F33, 0xA2B01F, 0xF0B126, 0x0087BF, 0xF18636, 0x0087BF, 0xB2B7BB, 0x72ACAE, 0x9C8AB4, 0x5A8770, 0xEEB424, 0x407887]
        let str = String(alphabet).unicodeScalars
        let unicode = Int(str[str.startIndex].value)
        if 65...90 ~= unicode {
            let hex = alphabetColors[unicode - 65]
            return UIColor(hex: UInt(hex), alpha: 1.0)
        }
        return UIColor.black
    }
    
    private static func fileExist(letter: String) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath.appending("/letterImages/\(letter).png")
        return FileManager.default.fileExists(atPath: imagesDirectoryPath)
    }
    
    private static func getLetterImage(letter: String) -> UIImage {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath.appending("/letterImages/\(letter).png")
        let image = UIImage(data: FileManager.default.contents(atPath: imagesDirectoryPath) ?? Data())
        return image ?? UIImage()
    }
    
    private static func saveImges(letter: String, img: Data?) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath.appending("/letterImages/\(letter).png")
        //var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false {
            FileManager.default.createFile(atPath: imagesDirectoryPath, contents: img, attributes:  nil)
        }
    }
}
