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
        if word.contains("'") { return false }
        
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
            NLTag("Determiner"): { !WordsGroup.articles.contains($0.lowercased())
            },
            NLTag("Particle"): { $0.lowercased() != "to" }
        ]
    }
}

extension String {
    func capitalisedFirst() -> String {
        guard !isEmpty else { return "" }

        return first!.uppercased() + dropFirst()
    }
    
    func capitalised(using capitaliser: Capitalisable, forcing: Bool = false) -> String {
        guard !isEmpty else { return "" }
        
        // Capitalise only in English
        if !forcing {
            guard let language = language, language == "en"
            else { return self }
        }
        
        var result = self
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = result
        
        var isFirst = true
        var lastWord: String?
        var lastRange: Range<Index>?
        var lastTag: NLTag?
        
        let options: NLTagger.Options = [.omitOther, .omitWhitespace, .omitPunctuation]
        tagger.enumerateTags(in: startIndex..<endIndex,
                             unit: .word,
                             scheme: .lexicalClass,
                             options: options) { tag, tokenRange in
            let word = String(result[tokenRange])
            
            if let tag = tag {
                if isFirst {
                    result.replaceSubrange(tokenRange, with: tag == NLTag("Noun") ?
                        word.capitalisedFirst() :
                        word.capitalized)
                    
                    isFirst = false
                    return true
                }
                
                if capitaliser.shouldCapitalise(word, tag: tag) {
                    result.replaceSubrange(tokenRange, with: tag == NLTag("Noun") ?
                        word.capitalisedFirst() :
                        word.capitalized)
                } else { result.replaceSubrange(tokenRange, with: word.lowercased()) }
                
                lastWord = word
                lastRange = tokenRange
                lastTag = tag
            }
            
            return true
        }
        
        if let lastTag = lastTag {
            result.replaceSubrange(lastRange!, with: lastTag == NLTag("Noun") ?
                lastWord!.capitalisedFirst() :
                lastWord!.capitalized)
        }
        
        return result
    }
    
    var language: String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        
        guard let language = recognizer.dominantLanguage else { return nil }
        
        return language.rawValue
    }
}
