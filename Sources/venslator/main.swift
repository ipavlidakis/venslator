import Foundation
import ArgumentParser

struct TranslateCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for translating strings files.",
        subcommands: [
            GoogleTranslateContainerCommand.self,
            NLPTranslationCommand.self
        ],
        defaultSubcommand: GoogleTranslateContainerCommand.self
    )
}

TranslateCommand.main()
