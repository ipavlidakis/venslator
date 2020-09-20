//
//  GoogleTranslateExportCommand.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//

import Foundation
import ArgumentParser

struct GoogleTranslateExportCommand: ParsableCommand {

    private enum CommandError: String, Error {
        case invalidFilePath = "The path you gave was invalid or the file doesn't exist"
        case gcloudNotInstalled = "GCloud dependency is not installed. Please visit https://cloud.google.com/sdk/docs/install for installation instructions"
        case failedToGenerateToken = "Failed to generate the gcloud token"
    }

    static var configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export the credentials for gcloud."
    )

    @Argument(help: "Path to your credentials file")
    var credentialsFile: String

    func run(
    ) throws {
        try print("Your gcloud token is\n\(Self.fetchGCloudToken(with: URL(fileURLWithPath: credentialsFile)))")
    }

    static func fetchGCloudToken(
        with credentialsFilePath: URL
    ) throws -> String {
        guard !credentialsFilePath.hasDirectoryPath, FileManager.default.fileExists(atPath: credentialsFilePath.relativePath) else {
            throw CommandError.invalidFilePath
        }

        setenv("GOOGLE_APPLICATION_CREDENTIALS", credentialsFilePath.relativePath, 1)

        let output = shell(
            launchPath: "/Users/ipavlidakis/tools/google-cloud-sdk/bin",
            command: "gcloud",
            arguments: ["-h"]
        )
        let isGCloudInstalled = !(output?.isEmpty ?? true)

        guard isGCloudInstalled else {
            throw CommandError.gcloudNotInstalled
        }

        let token = shell(
            launchPath: "/Users/ipavlidakis/tools/google-cloud-sdk/bin",
            command: "gcloud",
            arguments: ["auth", "application-default", "print-access-token"]
        )

        guard let generatedToken = token?.trimmingCharacters(in: .newlines) else {
            throw CommandError.gcloudNotInstalled
        }
        print("GENERATED TOKEN: \(generatedToken)")
        return generatedToken
    }
}
