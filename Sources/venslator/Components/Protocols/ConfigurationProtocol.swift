//
//  ConfigurationProtocol.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

protocol ConfigurationProtocol {

    var sourceLanguage: String { get }
    var targetLanguage: String  { get }
    var inputPath: URL  { get }
    var outputPath: URL  { get }
    var apiKey: String { get }
    var fileHeader: String? { get }
    var concurrentOperations: Int { get }
    var sortKeysAlphabetically: Bool { get }
}
