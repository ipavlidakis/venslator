import Foundation
import ArgumentParser
import Network

private let operationQueue = CompletionBlockOperationQueue(maxNumberOfConcurrentOperations: 1, completionBlock:  { operations in
    guard let operation = operations.first as? ExecutionFlowProtocol else {
        exit(EXIT_FAILURE)
    }

    switch operation.state {
        case .success: exit(EXIT_SUCCESS)
        case .cancelled: exit(ECANCELED)
        case .failure(let error):
            print("Finished with error: \(error)")
            exit(EXIT_FAILURE)
        default:
            exit(EXIT_FAILURE)
    }
})

enum AvailableAPI: String {
    case nlpTranslation = "nlptranslation"
    case googleTranslate = "gtranslate" // requires setup as described here https://cloud.google.com/sdk/docs/install
}

struct TranslateCommand: ParsableCommand {
    @Argument(help: "Language code of source file")
    var sourceLanguage: String

    @Argument(help: "Language code of translation")
    var targetLanguage: String

    @Argument(help: "Path to a single file or directory to translate.")
    var path: String

    @Option(name: .shortAndLong, help: "Which API/service to use")
    var api: String = AvailableAPI.nlpTranslation.rawValue

    @Option(name: .long, help: "The key required for the API/service")
    var apiKey: String

    @Option(name: .long, help: "Path to save output file(s).")
    var outputPath: String?

    @Option(name: .shortAndLong, help: "Words that you don't want to translate(suppoted only on NLPTranslation API)")
    var protectedWords: String?

    func run(
    ) throws {
        let targetLanguages: [String] = targetLanguage.split(separator: ",").map { String($0) }
        let protectedWords = self.protectedWords?.split(separator: ",").map { String($0) } ?? []
        let api: AvailableAPI = {
            switch self.api {
                case AvailableAPI.googleTranslate.rawValue:
                    return .googleTranslate
                default:
                    return .nlpTranslation

            }
        }()

        let operations = try makeOperations(
            for: api,
            targetLanguages: targetLanguages,
            protectedWords: protectedWords
        )

        if targetLanguages.endIndex > 1 {
            print("Will translate to \(targetLanguages.endIndex) languages: \(targetLanguages)")
        }
        operationQueue.addOperations(operations, waitUntilFinished: true)
    }

    private func makeOperations(
        for api: AvailableAPI,
        targetLanguages: [String],
        protectedWords: [String]
    ) throws -> [Operation] {
        switch api {
            case .nlpTranslation:
                return try targetLanguages.map {
                    try TranslationFlowOperation(
                        configuration: NLPTranslationOperation.makeConfiguration(for: $0, protectedWords: protectedWords, command: self),
                        fileWritter: StringsFileWritter(),
                        operationURLRequestFactory: NLPTranslationOperation.makeRequest,
                        operationFactory: NLPTranslationOperation.makeOperation)
                }
            case .googleTranslate:
                return try targetLanguages.map {
                    try TranslationFlowOperation(
                        configuration: GoogleTranslationOperation.makeConfiguration(for: $0, command: self),
                        fileWritter: StringsFileWritter(),
                        operationURLRequestFactory: GoogleTranslationOperation.makeRequest,
                        operationFactory: GoogleTranslationOperation.makeOperation)
                }
        }
    }
}

TranslateCommand.main()
