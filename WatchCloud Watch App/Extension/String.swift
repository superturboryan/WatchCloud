//
//  String.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-22.
//

// https://stackoverflow.com/questions/35897807/how-should-i-remove-all-the-empty-lines-from-a-string
extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
    var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}
