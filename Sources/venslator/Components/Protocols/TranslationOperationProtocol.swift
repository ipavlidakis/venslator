//
//  TranslationOperationProtocol.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 19/09/2020.
//

import Foundation

protocol TranslationOperationProtocol {

    var state: TranslationOperationState { get }

    var key: String { get }

    var value: String { get }
}
