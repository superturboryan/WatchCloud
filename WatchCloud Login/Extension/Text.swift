//
//  Text.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-03.
//

import SwiftUI

extension Text {
    static func md(_ markdownText: String) -> Text {
        var attributedString = try! AttributedString(
            markdown: markdownText,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        attributedString.foregroundColor = Color.primary
        return Text(attributedString)
    }
}
