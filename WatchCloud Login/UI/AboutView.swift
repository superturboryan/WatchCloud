//
//  AboutView.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-02.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State var aboutItems = AboutItem.all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(aboutItems, id: \.self) { item in
                        if !item.text.isEmpty {
                            ExpandableSection {
                                ForEach(item.text, id: \.self) { text in
                                    Text.md(text)
                                }
                            } header: {
                                Text(item.title)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .textCase(.none)
                                    .foregroundStyle(colorScheme.lessReadableText)
                                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .padding(.trailing, 4)
                                    .minimumScaleFactor(0.9)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                        } else {
                            Text(item.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                    
                    PoweredBySCView()
                        .fullWidth()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                .padding(.top, -10)
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .tint(.scOrangeLight)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Text("Close") }
                        .tint(.scOrangeLight)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Text(Config.appVersion)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(colorScheme.lessReadableText)
                }
            }
        }
    }
}

struct AboutItem: Hashable {
    let title: String
    let text: [String]
    
    static let all: [AboutItem] = [
        
        AboutItem(title: String(localized: "Frequently Asked Questions"), text: []),
        AboutItem(title: String(localized: "What is this app?"), text: [String(localized:
            """
            **WatchCloud is a watchOS app that makes it possible to stream SoundCloud directly to your Apple Watch.**

            This **iOS** app is used to connect WatchCloud to your SoundCloud account.
            """),
        ]),
        AboutItem(title: String(localized: "Can I delete this app from my phone?"), text: [String(localized:
            """
            After completing the instructions to connect your account, verify that WatchCloud has been connected on your Apple Watch. The watchOS app will remain connected without this iOS app.
            
            You can then delete this app from your iPhone. You can download this app again from the App Store if you need to reconnect your SoundCloud account.
            """),
        ]),
        AboutItem(title: String(localized: "Can I connect to SoundCloud on my watch?"), text: [String(localized:
            """
            Yes, but **there may be issues displaying the webpage for some of the login methods.**
            
            All login methods (soundcloud.com, Apple ID, FB, Google) work from this iPhone app.
            """),
        ]),
        AboutItem(title: String(localized: "Where can I get help?"), text: [String(localized:
            """
            You can send an email to **[watchcloud.app@gmail.com](mailto:watchcloud.app@gmail.com)** 💌
            
            You can also visit the **[issues page](https://github.com/superturboryan/WatchCloud-Privacy-Policy/issues)** to see questions from the community 👋
            """),
        ]),
        AboutItem(title: String(localized: "Legal"), text: []),
        AboutItem(title: String(localized:"WatchCloud Privacy Policy"), text: [String(localized:
            """
            **[Tap here](https://github.com/superturboryan/WatchCloud-Privacy-Policy/)**
            """),
        ]),
        AboutItem(title: String(localized: "SoundCloud API Terms of Use"), text: [String(localized:
            """
            **[Tap here](https://developers.soundcloud.com/docs/api/terms-of-use)**
            """),
        ]),
    ]
}

#Preview {
    AboutView()
}

//AboutItem(title: "", text: [
//    """
//    """,
//])
