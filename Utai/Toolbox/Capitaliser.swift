//
//  Capitaliser.swift
//  Capitaliser
//
//  Created by Toto Minai on 2021/07/29.
//

import Foundation
import NaturalLanguage

class WordsGroup {
    static let coOrdinatingConjunctions = [
        "for",
        "and",
        "nor",
        "but",
        "or",
        "yet",
        "so",
    ]
    
    static let articles = [ "a", "an", "the" ]
}


protocol Capitalisable {
    var mustCapitaliseTags: [NLTag] { get }
    var mustntCapitaliseTags: [NLTag] { get }
    var specialRules: [NLTag: (String) -> Bool] { get }
}

extension Capitalisable {
    func shouldCapitalise(_ word: String, tag: NLTag) -> Bool {
        if mustCapitaliseTags.contains(tag) &&
            !mustntCapitaliseTags.contains(tag) {
            return true
        }
        
        if let rule = specialRules[tag] {
            return rule(word)
        }
        
        return true
    }
}

class Capitalisers {
    // Rules from 'The Associated Press Stylebook'
    class APCapitaliser: Capitalisable {
        let mustCapitaliseTags = [
            NLTag("Noun"),
            NLTag("Pronoun"),
            NLTag("Verb"),
            NLTag("Adjective"),
            NLTag("Adverb"),
        ]
        
        let mustntCapitaliseTags = [
            NLTag("Particle"),
        ]
        
        let specialRules: [NLTag: (String) -> Bool] = [
            NLTag("Preposition"): { $0.count >= 4 },
            NLTag("Conjunction"): {
                !WordsGroup.coOrdinatingConjunctions.contains($0.lowercased()) &&
                !["as", "if"].contains($0.lowercased())
            },
            NLTag("Determiner"): { !WordsGroup.articles.contains($0.lowercased()) }
        ]
    }
    
    // Rules from Wikipedia
    class WPCapitaliser: Capitalisable {
        let mustCapitaliseTags = [
            NLTag("Noun"),
            NLTag("Pronoun"),
            NLTag("Verb"),
            NLTag("Adjective"),
            NLTag("Adverb"),
        ]
        
        let mustntCapitaliseTags = [NLTag]()
        
        let specialRules: [NLTag: (String) -> Bool] = [
            NLTag("Preposition"): { $0.count >= 5 },
            NLTag("Conjunction"): {
                !WordsGroup.coOrdinatingConjunctions.contains($0.lowercased())
            },
            NLTag("Determiner"): { !WordsGroup.articles.contains($0.lowercased()) },
            NLTag("Particle"): { $0.lowercased() != "to" }
        ]
    }
}

extension String {
    func capitalisedFirst() -> String {
        guard !isEmpty else { return "" }
        guard isLatin else { return self }

        return first!.uppercased() + dropFirst()
    }
    
    func tagged() -> [(NLTag?, Range<Index>)] {
        var result = [(NLTag?, Range<Index>)]()
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = self
        
        let options: NLTagger.Options = [
            .omitOther, .omitWhitespace, .omitPunctuation, .joinContractions, .joinNames]
        tagger.enumerateTags(in: startIndex..<endIndex,
                             unit: .word,
                             scheme: .lexicalClass,
                             options: options) { tag, tokenRange in
            result.append((tag, tokenRange))
            
            return true
        }
        
        return result
    }
    
    func capitalised(using capitaliser: Capitalisable, forcing: Bool = false) -> String {
        guard !isEmpty else { return "" }
        
        // Capitalise only in English
        if !forcing {
            guard let language = language, language == "en"
            else { return self }
        }
        
        var result = self
        
        let tagged = tagged()
        tagged.enumerated().forEach { index, element in
            let (tag, tokenRange) = element
            
            let word = String(self[tokenRange])
            let newStartIndex = result.index(result.startIndex, offsetBy: tokenRange.lowerBound.utf16Offset(in: self))
            let newEndIndex = result.index(result.startIndex, offsetBy: tokenRange.upperBound.utf16Offset(in: self))
            let newRange = newStartIndex..<newEndIndex
            
            if let tag = tag {
                if word.isEmpty || word.first!.isNumber { return }
                
                if index == 0 || index == tagged.count-1 ||
                    capitaliser.shouldCapitalise(word, tag: tag) {
                    result.replaceSubrange(newRange, with: tag == NLTag("Noun") ||
                                           tag == NLTag("OtherWord") ?
                        word.capitalisedFirst() :
                        word.capitalized)
                } else { result.replaceSubrange(newRange, with: word.lowercased()) }
            }
        }
        
        return result
    }
    
    var language: String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        
        guard let language = recognizer.dominantLanguage else { return nil }
        
        return language.rawValue
    }
    
    var isLatin: Bool {
        range(of: "\\P{Latin}", options: .regularExpression) == nil
    }
}
