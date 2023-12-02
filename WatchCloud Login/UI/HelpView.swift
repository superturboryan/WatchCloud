//
//  HelpView.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-02.
//

import SwiftUI

struct HelpItem: Hashable {
    let title: String
    let text: [String]
}

struct HelpView: View {
    @State var helpItems: [HelpItem] = [
        HelpItem(title: "Can I delete this app?", text: ["Yes!"]),
        HelpItem(title: "What does it do?", text: ["Yes!", "Yes!", "Yes!"]),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List(helpItems, id: \.self) { item in
                    ExpandableSection {
                        ForEach(item.text, id: \.self) { text in
                            Text(text)
                        }
                    } header: {
                        Text(item.title)
                            .font(.headline)
                    }
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Help")
        }
    }
}

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

#Preview {
    HelpView()
}
