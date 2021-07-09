//
//  CustomText.swift
//  Utai
//
//  Created by Toto Minai on 2021/07/08.
//

import SwiftUI

enum CustomFont {
    static let CJKFont = NSFont.systemFont(ofSize: 13.6)
    static let LatinFont = NSFont(name: "Yanone Kaffeesatz", size: 16)!
    static let LatinFontCharacterSet = LatinFont.fontDescriptor.object(forKey: .characterSet) as! NSCharacterSet
    
    static func LatinParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = CustomFont.LatinFont.ascender -
                                  CustomFont.LatinFont.descender
        style.lineSpacing = 4
        
        return style
    }
    
    static func CJKParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = CustomFont.LatinFont.ascender -
                                  CustomFont.LatinFont.descender
        style.lineSpacing = 4
        
        return style
    }
}

struct CustomTextRepresented: NSViewRepresentable {
    let text: String
    @Binding var hasCJK: Bool
    @Binding var show: Bool
    
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
                                   attributes: CustomFont.LatinFontCharacterSet.characterIsMember(ch.utf16.first!) ?
                                   LatinAttributes : CJKAttributes))
        }
        
        let textField = NSTextField(labelWithAttributedString: attributedString)
        // TODO: isSelectable makes custom font not work
        // textField.isSelectable = true
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        DispatchQueue.main.async {
            let attributedString = NSMutableAttributedString(string: "")
            text.forEach { ch in
                if CustomFont.LatinFontCharacterSet.characterIsMember(ch.utf16.first!) {
                    attributedString.append(
                        NSAttributedString(string: String(ch),
                                           attributes: LatinAttributes))
                } else {
                    hasCJK = true
                    attributedString.append(
                        NSAttributedString(string: String(ch),
                                           attributes: CJKAttributes))
                }
            }
            
            nsView.attributedStringValue = attributedString
            withAnimation(.easeOut) { show = true }
        }
    }
}

struct CustomText: View {
    let text: String
    @State private var hasCJK: Bool = false
    @State private var show: Bool = false
    
    var body: some View {
        CustomTextRepresented(text: text, hasCJK: $hasCJK, show: $show)
            .offset(y: hasCJK ? 1 : 0)
            .opacity(show ? 1 : 0)
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
