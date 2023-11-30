//
//  ContentView.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                WCSessionHandler.shared.sendMessage()
            }, label: {
                Text("Send message to watch")
            })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
