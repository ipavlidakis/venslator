//
//  NLPTranslationCommand.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//

import Foundation
import ArgumentParser

struct NLPTranslationCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "nlptranslate",
        abstract: "Translate using NLP Translate API"
    )

    @Argument(help: "Language code of source file")
    var sourceLanguage: String

    @Argument(help: "Language code of translation")
    var targetLanguage: String

    @Argument(help: "Path to a single file or directory to translate.")
    var path: String

    @Option(name: .shortAndLong, help: "The key required for the API/service")
    var apiKey: String

    @Option(name: .shortAndLong, help: "Path to save output file(s).")
    var outputPath: String?

    @Option(name: .shortAndLong, help: "Words that you don't want to translate(suppoted only on NLPTranslation API)")
    var protectedWords: String?

    func run(
    ) throws {
        let targetLanguages: [String] = targetLanguage.split(separator: ",").map { String($0) }
        let protectedWords = self.protectedWords?.split(separator: ",").map { String($0) } ?? []

        let operations = try targetLanguages.map {
            try TranslationFlowOperation(
                configuration: NLPTranslationOperation.makeConfiguration(for: $0, protectedWords: protectedWords, command: self),
                fileWritter: StringsFileWritter(),
                operationURLRequestFactory: NLPTranslationOperation.makeRequest,
                operationFactory: NLPTranslationOperation.makeOperation)
        }

        if targetLanguages.endIndex > 1 {
            print("Will translate to \(targetLanguages.endIndex) languages: \(targetLanguages)")
        }

        commandExecutationQueue.addOperations(operations, waitUntilFinished: true)
    }
}

