//
//  GoogleTranslateContainerCommand.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//

import Foundation
import ArgumentParser

struct GoogleTranslateContainerCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "gtranslate",
        abstract: "Utitlies for Google API translation",
        subcommands: [
            GoogleTranslateAutoCommand.self,
            GoogleTranslateCommand.self,
            GoogleTranslateExportCommand.self
        ]
    )
}
