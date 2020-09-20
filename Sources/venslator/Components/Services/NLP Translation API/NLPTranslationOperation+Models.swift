//
//  NLPTranslationOperation+RequestBody.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

extension NLPTranslationOperation {

    struct TranslationRequest {

        let fromLanguage: String
        let toLanguage: String
        let text: String
        let protectedWords: [String]

        private enum CodingKeys: String, CodingKey {
            case fromLanguage = "from"
            case toLanguage = "to"
            case text
            case protectedWords = "protected_words"
        }

        var toFormURLEncodedData: Data? {
            return [
                CodingKeys.fromLanguage.rawValue: fromLanguage,
                CodingKeys.toLanguage.rawValue: toLanguage,
                CodingKeys.text.rawValue: text,
                CodingKeys.protectedWords.rawValue: protectedWords,
            ].compactMap { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        }
    }

    struct TranslationResponse: Codable, Equatable, TranslationOperationResultModel {
        let status: Int?
        let from: String?
        let to: String?
        let originalText: String?
        let translatedText: [String: String]
        let translatedCharacters: Int?

        var value: String {
            guard let to = to, let text = translatedText[to] else { return "" }
            return text
        }

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case from = "from"
            case to = "to"
            case originalText = "original_text"
            case translatedText = "translated_text"
            case translatedCharacters = "translated_characters"
        }
    }
}
