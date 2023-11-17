//
//  AppLauncher.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-13.
//

import SwiftUI

@main
struct AppLauncher {
    
    static func main() throws {
        Config.isTestEnvironment ?
            TestApp.main() :
            WatchCloud_Watch_AppApp.main()
    }
}

struct TestApp: App {
    var body: some Scene {
        WindowGroup { Text(verbatim: "Running unit tests") }
    }
}
