//
//  FlowError.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

enum FlowError: Error {
    case inputFileNotFound(path: String)
    case invalidFileContentsFormat(path: String)

    var localizedError: String {
        switch self {
            case .inputFileNotFound(let path):
                return "File not found at path: \(path)."
            case .invalidFileContentsFormat(path: let path):
                return "Contents format of file at :\(path) is invalid."
        }
    }
}
