//
//  GoogleTranslateCommand.swift
//  ArgumentParser
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//

import Foundation
import ArgumentParser

struct GoogleTranslateCommand: ParsableCommand, GoogleTranslationOperationInput {

    static var configuration = CommandConfiguration(
        commandName: "translate",
        abstract: "Translate using Goolge Analytics API. Requires gcloud. Help about how to install it can be found at https://cloud.google.com/sdk/docs/install"
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

    func run(
    ) throws {
        try Self.translate(
            sourceLanguage: self.sourceLanguage,
            targetLanguage: self.targetLanguage,
            path: self.path,
            apiKey: self.apiKey,
            outputPath: self.outputPath,
            command: self
        )
    }

    static func translate(
        sourceLanguage: String,
        targetLanguage: String,
        path: String,
        apiKey: String,
        outputPath: String?,
        command: GoogleTranslationOperationInput
    ) throws {

        let targetLanguages: [String] = targetLanguage.split(separator: ",").map { String($0) }

        let operations = try targetLanguages.map {
            try TranslationFlowOperation(
                configuration: GoogleTranslationOperation.makeConfiguration(for: $0, command: command),
                fileWritter: StringsFileWritter(),
                operationURLRequestFactory: GoogleTranslationOperation.makeRequest,
                operationFactory: GoogleTranslationOperation.makeOperation)
        }

        if targetLanguages.endIndex > 1 {
            print("Will translate to \(targetLanguages.endIndex) languages: \(targetLanguages)")
        }

        commandExecutationQueue.addOperations(operations, waitUntilFinished: true)
    }
}
