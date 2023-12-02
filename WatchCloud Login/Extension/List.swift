//
//  List.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-02.
//

import SwiftUI

struct ExpandableSection<Content: View, Header: View>: View {
    
    @State var isExpanded = false
    
    let content: () -> Content
    let header: () -> Header
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Section(isExpanded: $isExpanded, content: content, header: header)
        } else {
            Section(content: content, header: header)
        }
    }
}
