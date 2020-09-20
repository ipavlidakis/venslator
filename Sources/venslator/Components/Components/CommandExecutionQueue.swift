//
//  CommandExecutionQueue.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//

import Foundation

let commandExecutationQueue = CompletionBlockOperationQueue(maxNumberOfConcurrentOperations: 1, completionBlock:  { operations in
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
