//
//  CustomText.swift
//  Utai
//
//  Created by Toto Minai on 2021/07/08.
//

import SwiftUI

enum CustomFont {
    static let CJKFont = NSFont(name: "Source Han Sans TC", size: NSFont.systemFontSize(for: .regular))!
    static let LatinFont = NSFont(name: "Yanone Kaffeesatz", size: 16)!
    static let LatinFontCharacterSet = LatinFont.fontDescriptor.object(forKey: .characterSet) as! NSCharacterSet
    
    static func LatinParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = CustomFont.LatinFont.ascender -
                                  CustomFont.LatinFont.descender
        return style
    }
    
    static func CJKParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        
        return style
    }
}

struct CustomText: NSViewRepresentable {
    let text: String
    
    let CJKAttributes: [NSAttributedString.Key: Any] = [
        .font: CustomFont.CJKFont.withWeight(.heavy),
        .paragraphStyle: CustomFont.LatinParagraphStyle(),
    ]
    
    let LatinAttributes: [NSAttributedString.Key: Any] = [
        .font: CustomFont.LatinFont.withWeight(.bold),
        .paragraphStyle: CustomFont.CJKParagraphStyle()
    ]
    
    func makeNSView(context: Context) -> NSTextField {
        let attributedString = NSMutableAttributedString(string: "")
        text.forEach { ch in
            attributedString.append(
                NSAttributedString(string: String(ch),
                                   attributes: CustomFont.LatinFontCharacterSet.characterIsMember(ch.utf16.first!) ? LatinAttributes : CJKAttributes))
        }
        
        let textField = NSTextField(labelWithAttributedString: attributedString)
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        DispatchQueue.main.async {
            let attributedString = NSMutableAttributedString(string: "")
            text.forEach { ch in
                attributedString.append(
                    NSAttributedString(string: String(ch),
                                       attributes: CustomFont.LatinFontCharacterSet.characterIsMember(ch.utf16.first!) ? LatinAttributes : CJKAttributes))
            }
            
            nsView.attributedStringValue = attributedString
        }
    }
    
    init(_ text: String) { self.text = text }
}

extension NSFont {
    func withWeight(_ weight: NSFont.Weight) -> NSFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [NSFontDescriptor.TraitKey: Any]) ?? [:]
        
        traits[.weight] = weight
        
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = NSFontDescriptor(fontAttributes: attributes)
        
        return NSFont(descriptor: descriptor, size: pointSize)!
    }
}
