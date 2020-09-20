//
//  StringsFileWritter.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

private extension String {

    var escapingQuotes: String { replacingOccurrences(of: "\"", with: "\\\"") }
}

struct StringsFileWritter: FileWritterProtocol {

    enum WriteOperationError: Error {
        case failed(_ error: Error)

        var localizedError: String {
            switch self {
                case .failed(let error):
                    return "Failed to write strings file with error: \(error)"
            }
        }
    }

    func write(
        _ data: [String: String],
        fileHeader: String?,
        to path: URL,
        alphabetically: Bool = true
    ) throws {
        do {
            var stringsToWrite = ""
            if let header = fileHeader {
                stringsToWrite += header + "\n\n"
            }

            var keys = Array(data.keys)
            if alphabetically {
                keys = keys.sorted()
            }

            let strings: [String] = keys.map {
                "\"" + $0.escapingQuotes + "\" = \"" + data[$0]!.escapingQuotes + "\";"
            }

            stringsToWrite += strings.joined(separator: "\n")

            try stringsToWrite.write(
                to: path,
                atomically: false,
                encoding: .utf8
            )
        } catch (let error) {
            throw WriteOperationError.failed(error)
        }
    }
}
