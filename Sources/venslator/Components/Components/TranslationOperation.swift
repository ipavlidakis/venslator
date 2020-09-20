//
//  TranslationOperation.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

enum TranslationOperationState {
    case none
    case completed(_ result: String)
    case failed(_ error: Error?)
}

final class TranslationOperation<Model: TranslationOperationResultModel & Decodable>: Operation, TranslationOperationProtocol {

    var value: String {
        switch state {
            case .completed(let result):
                return result
            default:
                assertionFailure("Failure state operation shouldn't be asked about it's value")
                return ""
        }
    }

    let key: String

    private(set) var state: TranslationOperationState = .none {
        didSet { _isFinished = true }
    }
    private let request: URLRequest
    private var numberOfRetriesLeft: Int
    private var dataTask: URLSessionTask? {
        didSet { dataTask?.resume() }
    }
    private var _isFinished: Bool = false {
        willSet { willChangeValue(for: \.isFinished) }
        didSet { didChangeValue(for: \.isFinished) }
    }

    private var lastData: Data?
    private var lastResponse: URLResponse?
    private var lastError: Error?

    override var isFinished: Bool { _isFinished }

    init(
        key: String,
        request: URLRequest,
        numberOfRetriesLeft: Int = 3
    ) {
        self.key = key
        self.request = request
        self.numberOfRetriesLeft = numberOfRetriesLeft

        super.init()
    }

    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }

    override func main() {
        super.main()
        execute()
    }

    private func execute() {
        guard !_isFinished, !isCancelled, numberOfRetriesLeft > 0 else {
            state = .failed(lastError)
            return
        }

        numberOfRetriesLeft -= 1

        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            self.lastData = data
            self.lastResponse = response
            self.lastError = error

            if error != nil {
                self.state = .failed(error)
            } else if let data = data, let translationResponse = try? JSONDecoder().decode(Model.self, from: data) {
                self.state = .completed(translationResponse.value)
            } else {
                print("Will retry operation: \(self.key)")
                self.execute()
            }
        })
    }
}
