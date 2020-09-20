//
//  ExecutionFlowProtocol.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

protocol ExecutionFlowProtocol {

    var state: ExecutionFlowState { get }
}

enum ExecutionFlowState {
    case none
    case success
    case cancelled
    case failure(_ error: Error)
}
