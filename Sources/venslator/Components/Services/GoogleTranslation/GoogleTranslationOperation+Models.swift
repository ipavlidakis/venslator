//
//  GoogleTranslationOperation+Models.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

extension GoogleTranslationOperation {

    struct TranslationRequest: Codable {

        let toLanguage: String
        let text: String
        let model: String = "base"

        private enum CodingKeys: String, CodingKey {
            case toLanguage = "target"
            case text = "q"
            case model
        }
    }

    struct TranslationResponse: Codable, Equatable, TranslationOperationResultModel {

        private let data: DataClass

        var from: String { data.translations.first!.detectedSourceLanguage }
        var value: String { data.translations.first!.translatedText }
        var model: String? { data.translations.first!.model }

        enum CodingKeys: String, CodingKey { case data = "data" }
    }

    private struct DataClass: Codable, Equatable {
        let translations: [TranslationElement]

        enum CodingKeys: String, CodingKey {
            case translations = "translations"
        }
    }

    private struct TranslationElement: Codable, Equatable {
        let translatedText: String
        let detectedSourceLanguage: String
        let model: String?

        enum CodingKeys: String, CodingKey {
            case translatedText = "translatedText"
            case detectedSourceLanguage = "detectedSourceLanguage"
            case model
        }
    }
}
