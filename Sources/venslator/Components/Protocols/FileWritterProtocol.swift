//
//  FileWritterProtocol.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

protocol FileWritterProtocol {

    func write(
        _ data: [String: String],
        fileHeader: String?,
        to path: URL,
        alphabetically: Bool
    ) throws
}
