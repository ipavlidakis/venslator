//
//  TranslationFlowOperation.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

private func controlledFetch(
    _ operations: [Operation],
    limit: Int = -1
) -> [Operation] {
    guard !operations.isEmpty,
          limit > -1,
          limit < operations.endIndex
    else { return operations }

    print("INFO: Limiting operations to the first \(limit)")
    return Array(operations[0..<limit])
}

final class TranslationFlowOperation: Operation, ExecutionFlowProtocol {

    typealias OperationURLRequestFactory = (_ configuration: ConfigurationProtocol, _ key: String, _ value: String) -> URLRequest
    typealias OperationFactory = (_ key: String, _ request: URLRequest) -> Operation

    private(set) var state: ExecutionFlowState = .none {
        didSet { _isFinished = true }
    }

    private let configuration: ConfigurationProtocol
    private let fileManager: FileManager = .default
    private let operationURLRequestFactory: OperationURLRequestFactory
    private let operationFactory: OperationFactory
    private let fileWritter: FileWritterProtocol

    private var dataTask: URLSessionTask?
    private var _isFinished: Bool = false {
        willSet { willChangeValue(for: \.isFinished) }
        didSet { didChangeValue(for: \.isFinished) }
    }

    override var isFinished: Bool { _isFinished }

    private lazy var operationQueue = CompletionBlockOperationQueue(
        maxNumberOfConcurrentOperations: configuration.concurrentOperations,
        progressBlock: flowProgressed,
        completionBlock: flowCompleted)

    init(
        configuration: ConfigurationProtocol,
        fileWritter: FileWritterProtocol,
        operationURLRequestFactory: @escaping OperationURLRequestFactory,
        operationFactory: @escaping OperationFactory
    ) {
        self.configuration = configuration
        self.fileWritter = fileWritter
        self.operationURLRequestFactory = operationURLRequestFactory
        self.operationFactory = operationFactory

        super.init()
    }
}

extension TranslationFlowOperation {

    private func readContents(
        of fileAtPath: URL
    ) -> [String: String] {
        guard let stringContent = try? String(contentsOf: fileAtPath) else {
            return  [:]
        }
        return stringContent.propertyListFromStringsFileFormat()
    }

    private func execute(
    ) throws {
        guard !isCancelled else { return }

        if !fileManager.fileExists(atPath: configuration.inputPath.relativePath) {
            throw FlowError.inputFileNotFound(path: configuration.inputPath.relativePath)
        }

        let operations = readContents(of: configuration.inputPath)
            .map { (key: $0.key, request: operationURLRequestFactory(configuration, $0.key, $0.value)) }
            .map { operationFactory($0.key, $0.request) }

        print("Translating \(operations.endIndex) strings from \(configuration.sourceLanguage) to \(configuration.targetLanguage) ...")
        #if DEBUG
        operationQueue.addOperations(controlledFetch(operations, limit: 3), waitUntilFinished: true)
        #else
        operationQueue.addOperations(operations, waitUntilFinished: true)
        #endif
    }

    private func flowProgressed(
        _ completed: Int,
        _ total: Int
    ) {
        print("Translation progress: \(completed) out \(total)")
    }

    private func flowCompleted(
        _ operations: [Operation]
    ) {
        let mappedOperations: [TranslationOperationProtocol] = operations.compactMap {  $0 as? TranslationOperationProtocol }
        let completedOperations: [String] = mappedOperations.compactMap {
            guard
                case TranslationOperationState.completed(let value) = $0.state
            else { return nil }
            return value
        }
        let failedOperations: [TranslationOperationProtocol] = mappedOperations.compactMap {
            guard
                case TranslationOperationState.failed(_) = $0.state
            else { return nil }
            return $0
        }
        guard completedOperations.endIndex == operations.endIndex else { return }
        var results: [String: String] = [:]
        mappedOperations.compactMap {
            guard
                case TranslationOperationState.completed(let value) = $0.state
            else { assertionFailure(); return nil }
            return [$0.key: value]
        }.forEach { results.merge($0, uniquingKeysWith: { lhs, _ in return lhs }) }

        do {
            try fileWritter.write(
                results,
                fileHeader: configuration.fileHeader,
                to: configuration.outputPath,
                alphabetically: configuration.sortKeysAlphabetically
            )

            if failedOperations.isEmpty {
                print("\(completedOperations.endIndex) strings were written at \(configuration.outputPath.relativePath)")
            } else {
                print("\(completedOperations.endIndex) strings were written and \(failedOperations.endIndex) strings failed to be written at \(configuration.outputPath.relativePath) ")
            }

            state = .success
        } catch (let error) {
            state = .failure(error)
        }
    }

    override func main() {
        do {
            try execute()
        } catch (let error) {
            state = .failure(error)
            return
        }
    }

    override func cancel() {
        dataTask?.cancel()
        state = .cancelled
    }
}
