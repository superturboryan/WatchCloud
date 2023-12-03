//
//  AboutView.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-02.
//

import SwiftUI

struct AboutView: View {
    
    @State var aboutItems = AboutItem.all
    
    var body: some View {
        NavigationView {
            VStack {
                List(aboutItems, id: \.self) { item in
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

struct AboutItem: Hashable {
    let title: String
    let text: [String]
    
    static let all: [AboutItem] = [
        AboutItem(title: "Can I delete this app?", text: ["Yes!"]),
        AboutItem(title: "What does it do?", text: ["Yes!", "Yes!", "Yes!"]),
    ]
}

#Preview {
    AboutView()
}
