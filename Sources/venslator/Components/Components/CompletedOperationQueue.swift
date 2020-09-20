//
//  CompletedOperationQueue.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

final class CompletionBlockOperationQueue: OperationQueue {

    private var observationToken: Any?

    private var hasAddedOperations: Bool = false
    private var addedOperations: [Operation] = []

    init(
        maxNumberOfConcurrentOperations noOfOperations: Int,
        progressBlock: ((_ completed: Int, _ total: Int) -> Void)? = nil,
        completionBlock: (([Operation]) -> Void)? = nil
    ) {
        super.init()
        self.maxConcurrentOperationCount = noOfOperations

        observationToken = observe(\.operationCount, changeHandler: { object, change in
            guard object.hasAddedOperations else { return }

            guard object.operationCount == 0 else {
                let completed = self.addedOperations.endIndex - object.operations.endIndex
                progressBlock?(completed, self.addedOperations.endIndex)
                return
            }
            completionBlock?(object.addedOperations)
        })
    }

    override func addOperations(
        _ ops: [Operation],
        waitUntilFinished wait: Bool
    ) {
        self.hasAddedOperations = true
        self.addedOperations = ops
        super.addOperations(ops, waitUntilFinished: wait)
    }
}
