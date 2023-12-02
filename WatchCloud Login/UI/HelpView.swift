//
//  HelpView.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-02.
//

import SwiftUI

struct HelpView: View {
    
    @State var helpItems = HelpItem.all
    
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

struct HelpItem: Hashable {
    let title: String
    let text: [String]
    
    static let all: [HelpItem] = [
        HelpItem(title: "Can I delete this app?", text: ["Yes!"]),
        HelpItem(title: "What does it do?", text: ["Yes!", "Yes!", "Yes!"]),
    ]
}

#Preview {
    HelpView()
}
