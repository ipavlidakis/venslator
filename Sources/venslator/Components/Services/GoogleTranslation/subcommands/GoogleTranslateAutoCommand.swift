//
//  GoogleTranslateAutoCommand.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//

import Foundation
import ArgumentParser

struct GoogleTranslateAutoCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "auto-translate",
        abstract: "Translate using Goolge Analytics API. The command will generate a new gcloud token and use. Requires gcloud. Help about how to install it can be found at https://cloud.google.com/sdk/docs/install"
    )

    @Argument(help: "Language code of source file")
    var sourceLanguage: String

    @Argument(help: "Language code of translation")
    var targetLanguage: String

    @Argument(help: "Path to a single file or directory to translate.")
    var path: String

    @Argument(help: "Path to your credentials file")
    var credentialsFilePath: String

    @Option(name: .shortAndLong, help: "Path to save output file(s).")
    var outputPath: String?

    func run(
    ) throws {
        let apiKey = try GoogleTranslateExportCommand.fetchGCloudToken(with: URL(fileURLWithPath: credentialsFilePath))
        try GoogleTranslateCommand.translate(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            path: path,
            apiKey: apiKey,
            outputPath: outputPath,
            command: SimpleConfiguration(sourceLanguage: sourceLanguage, path: path, apiKey: apiKey, outputPath: outputPath)
        )
    }

    struct SimpleConfiguration: GoogleTranslationOperationInput {
        let sourceLanguage: String
        let path: String
        let apiKey: String
        let outputPath: String?
    }
}

