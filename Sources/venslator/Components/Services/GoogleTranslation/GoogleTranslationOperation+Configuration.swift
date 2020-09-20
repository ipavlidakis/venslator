//
//  GoogleTranslationOperation+Configuration.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

extension GoogleTranslationOperation {

    struct Configuration: Codable, ConfigurationProtocol {
        let sourceLanguage: String
        let targetLanguage: String
        let inputPath: URL
        let outputPath: URL
        let apiKey: String
        let fileHeader: String?
        let concurrentOperations: Int
        let sortKeysAlphabetically: Bool

        private static func extractURL(
            folderName: String,
            fileName: String,
            from path: String?,
            fallback: URL
        ) -> URL {
            var result: URL
            if let _path = path {
                result = URL(fileURLWithPath: _path)
                if !result.hasDirectoryPath { result.deleteLastPathComponent() }
            } else if fallback.hasDirectoryPath {
                result = fallback
            } else {
                result = fallback
                while result.lastPathComponent.contains(".lproj") || result.lastPathComponent.contains(".string") || !result.hasDirectoryPath {
                    result = result.deletingLastPathComponent()
                }
            }

            assert(!result.relativePath.isEmpty)

            return result.appendingPathComponent(folderName).appendingPathComponent(fileName)
        }

        init(
            sourceLanguage: String,
            targetLanguage: String,
            path: String,
            outputPath: String?,
            apiKey: String,
            fileHeader: String? = nil,
            concurrentOperations: Int = 10,
            sortKeysAlphabetically: Bool = true
        ) throws {
            self.sourceLanguage = sourceLanguage
            self.targetLanguage = targetLanguage
            self.inputPath = URL(fileURLWithPath: path).appendingPathComponent("\(sourceLanguage).lproj").appendingPathComponent("Localizable.strings")
            self.outputPath = Self.extractURL(folderName: "\(targetLanguage).lproj", fileName: "Localizable.strings", from: outputPath, fallback: self.inputPath)
            self.apiKey = apiKey
            self.fileHeader = fileHeader
            self.concurrentOperations = concurrentOperations
            self.sortKeysAlphabetically = sortKeysAlphabetically

            do {
                try FileManager.default.createDirectory(
                    at: self.outputPath.deletingLastPathComponent(),
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch (let error) {
                throw error
            }
        }

        private static func directoryExists(
            _ atPath: String
        ) -> Bool {
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory)
            return exists && isDirectory.boolValue
        }
    }
}
