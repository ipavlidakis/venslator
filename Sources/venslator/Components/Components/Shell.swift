//
//  Shell.swift
//  venslator
//
//  Created by Ilias Pavlidakis on 20/09/2020.
//  Source: https://stackoverflow.com/a/26973266/1626335

import Foundation

func printShell(
    launchPath: String = "/bin",
    command: String? = nil,
    arguments: [String] = []
) {
    let output = shell(
        launchPath: launchPath,
        command: command,
        arguments: arguments
    )

    if (output != nil) {
        print(output!)
    }
}

func shell(
    launchPath: String = "/bin",
    command: String? = nil,
    arguments: [String] = []
) -> String? {
    var executable = launchPath
    if let command = command {
        if !executable.hasSuffix("/"), !executable.isEmpty {
            executable += "/"
        }

        executable += command
    }

    let task = Process()
    task.launchPath = executable
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output
}
